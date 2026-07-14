import {db} from "../config";
import {companySettings, supportContact} from "../settings";
import {bookingMessage} from "../templates/emailTemplates";
import {logNotification} from "../utils/logger";
import type {Booking, SendResult} from "../types";
import {sendAdminBookingAlert, sendCustomerConfirmation} from "./emailService";
import {sendPush} from "./pushService";
import {sendBookingAlert} from "./whatsappService";

/** Owner/staff, resolved from the users collection rather than hardcoded. */
async function managers() {
  const snapshot = await db.collection("users").where("role", "in", ["owner", "staff"]).get();
  return {
    ids: snapshot.docs.map((doc) => doc.id),
    emails: snapshot.docs
      .map((doc) => doc.get("email"))
      .filter((value): value is string => typeof value === "string" && value.length > 0),
  };
}

type Summary = Record<string, SendResult>;

/**
 * Notifications must never prevent a booking, so every channel is awaited
 * independently and its outcome recorded. One channel failing does not stop the
 * others, and nothing here throws.
 */
async function record(bookingId: string, channel: "email" | "whatsapp" | "push", provider: string, result: SendResult) {
  await logNotification(bookingId, channel, provider, result);
  return result;
}

export async function notifyBookingCreated(booking: Booking, bookingId: string): Promise<Summary> {
  const [support, company, staff] = await Promise.all([supportContact(), companySettings(), managers()]);

  const forCustomer = bookingMessage("created_customer", booking, bookingId, support);
  const forManagers = bookingMessage("created_managers", booking, bookingId, support);

  // adminEmail is the configured destination; owner/staff addresses back it up.
  const adminEmails = [...new Set([company.adminEmail, ...staff.emails].filter(Boolean))];

  const [customerEmail, adminEmail, adminWhatsapp, managerPush] = await Promise.all([
    sendCustomerConfirmation(booking.email, forCustomer, bookingId)
      .then((r) => record(bookingId, "email", "trigger-email", r)),
    sendAdminBookingAlert(adminEmails, forManagers, bookingId)
      .then((r) => record(bookingId, "email", "trigger-email", r)),
    sendBookingAlert("NEW BOOKING", booking, bookingId, company.adminWhatsapp)
      .then((r) => record(bookingId, "whatsapp", "meta", r)),
    sendPush(staff.ids, forManagers, bookingId)
      .then((r) => record(bookingId, "push", "fcm", r)),
  ]);

  return {customerEmail, adminEmail, adminWhatsapp, managerPush};
}

export async function notifyBookingStatusChanged(
  booking: Booking,
  bookingId: string,
  status: string,
): Promise<Summary> {
  const [support, company] = await Promise.all([supportContact(), companySettings()]);

  // Customer-facing outcomes: email + push to the customer. No WhatsApp.
  if (["approved", "declined", "completed"].includes(status)) {
    const message = bookingMessage(status, booking, bookingId, support);
    const [customerEmail, customerPush] = await Promise.all([
      sendCustomerConfirmation(booking.email, message, bookingId)
        .then((r) => record(bookingId, "email", "trigger-email", r)),
      sendPush([booking.userId], message, bookingId)
        .then((r) => record(bookingId, "push", "fcm", r)),
    ]);
    return {customerEmail, customerPush};
  }

  // A cancellation is an owner alert: email + WhatsApp + push to staff.
  if (status === "cancelled") {
    const staff = await managers();
    const message = bookingMessage("cancelled_managers", booking, bookingId, support);
    const adminEmails = [...new Set([company.adminEmail, ...staff.emails].filter(Boolean))];
    const [adminEmail, adminWhatsapp, managerPush] = await Promise.all([
      sendAdminBookingAlert(adminEmails, message, bookingId)
        .then((r) => record(bookingId, "email", "trigger-email", r)),
      sendBookingAlert("BOOKING CANCELLED", booking, bookingId, company.adminWhatsapp)
        .then((r) => record(bookingId, "whatsapp", "meta", r)),
      sendPush(staff.ids, message, bookingId)
        .then((r) => record(bookingId, "push", "fcm", r)),
    ]);
    return {adminEmail, adminWhatsapp, managerPush};
  }

  return {};
}
