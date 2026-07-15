import {reference} from "../types";
import {customerReceiptBody, ownerReceiptBody, oneLine, statusLabel} from "./bookingFormat";
import type {Booking, ChannelMessage, SupportContact} from "../types";

/**
 * Single source for notification wording so push, email, and WhatsApp stay
 * aligned. Every customer-facing body keeps the booking reference, destination,
 * status, and support details visible.
 */
export function bookingMessage(
  kind: string,
  booking: Booking,
  bookingId: string,
  support: SupportContact,
): ChannelMessage {
  const ref = reference(bookingId);
  switch (kind) {
  case "created_managers":
    return {
      title: "New Travel365 booking",
      subject: "New Booking Received",
      heading: "New booking received",
      body: `${oneLine(booking.fullName)} submitted booking ${ref} for ${oneLine(booking.destination)}.`,
      receiptBody: ownerReceiptBody(
        `${oneLine(booking.fullName)} submitted a new Travel365 booking.`,
        booking,
        bookingId,
      ),
    };
  case "created_customer":
    return {
      title: "Travel365 booking received",
      subject: "Booking Confirmation",
      heading: "We received your booking",
      body: `Hello ${oneLine(booking.fullName)}, your booking ${ref} to ${oneLine(booking.destination)} is awaiting review.`,
      receiptBody: customerReceiptBody(
        `Hello ${oneLine(booking.fullName)}, your Travel365 booking is safely received. Our consultant will contact you shortly.`,
        booking,
        bookingId,
        support,
      ),
    };
  case "declined":
    return {
      title: "Booking declined",
      subject: "Travel365 booking declined",
      heading: "Your booking was declined",
      body: `Your booking ${ref} to ${oneLine(booking.destination)} was declined.`,
      receiptBody: customerReceiptBody(
        `Your booking was declined: ${oneLine(booking.declineReason, "Please contact Travel365.")}`,
        booking,
        bookingId,
        support,
      ),
    };
  case "cancelled_managers":
    return {
      title: "Booking cancelled",
      subject: "Travel365 booking cancelled",
      heading: "Booking cancelled",
      body: `${oneLine(booking.fullName)} cancelled booking ${ref} for ${oneLine(booking.destination)}.`,
      receiptBody: ownerReceiptBody(
        `${oneLine(booking.fullName)} cancelled this Travel365 booking.`,
        booking,
        bookingId,
      ),
    };
  default:
    return {
      title: `Booking ${statusLabel(kind)}`,
      subject: `Travel365 booking ${statusLabel(kind)}`,
      heading: `Your booking is ${statusLabel(kind)}`,
      body: `Your booking ${ref} to ${oneLine(booking.destination)} is now ${statusLabel(kind)}.`,
      receiptBody: customerReceiptBody(
        `Your booking is now ${statusLabel(kind)}.${booking.ownerResponse ? ` ${oneLine(booking.ownerResponse)}` : ""}`,
        booking,
        bookingId,
        support,
      ),
    };
  }
}

export function emailHtml(heading: string, body: string, bookingId: string) {
  const escape = (value: string) =>
    value
      .replace(/&/g, "&amp;")
      .replace(/</g, "&lt;")
      .replace(/>/g, "&gt;")
      .replace(/"/g, "&quot;");
  const formattedBody = escape(body).replace(/\n/g, "<br>");
  return [
    "<div style=\"margin:0;background:#faf9f6;padding:24px;font-family:Arial,sans-serif;color:#18181b\">",
    "<div style=\"max-width:560px;margin:0 auto;background:#ffffff;border:1px solid #e7e5e4;border-radius:12px;padding:24px\">",
    "<p style=\"margin:0 0 12px;color:#c98224;font-weight:700;letter-spacing:.08em;text-transform:uppercase;font-size:12px\">Travel365</p>",
    `<h2 style="margin:0 0 16px;color:#111827;font-size:24px">${escape(heading)}</h2>`,
    `<p style="margin:0 0 18px;line-height:1.6;color:#3f3f46">${formattedBody}</p>`,
    `<p style="margin:18px 0 0;padding-top:16px;border-top:1px solid #e7e5e4;color:#71717a;font-size:13px">Booking reference: <strong style="color:#111827">${reference(bookingId)}</strong></p>`,
    "</div>",
    "</div>",
  ].join("");
}
