import {supportLine} from "../settings";
import {reference} from "../types";
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
      body: `${booking.fullName} submitted booking ${ref} for ${booking.destination}.`,
    };
  case "created_customer":
    return {
      title: "Travel365 booking received",
      subject: "Booking Confirmation",
      heading: "We received your booking",
      body: `Hello ${booking.fullName}, your booking ${ref} to ${booking.destination} is awaiting review. Our consultant will contact you shortly.${supportLine(support)}`,
    };
  case "declined":
    return {
      title: "Booking declined",
      subject: "Travel365 booking declined",
      heading: "Your booking was declined",
      body: `Your booking ${ref} to ${booking.destination} was declined: ${booking.declineReason || "Please contact Travel365."}${supportLine(support)}`,
    };
  case "cancelled_managers":
    return {
      title: "Booking cancelled",
      subject: "Travel365 booking cancelled",
      heading: "Booking cancelled",
      body: `${booking.fullName} cancelled booking ${ref} for ${booking.destination}.`,
    };
  default:
    return {
      title: `Booking ${kind}`,
      subject: `Travel365 booking ${kind}`,
      heading: `Your booking is ${kind}`,
      body: `Your booking ${ref} to ${booking.destination} is now ${kind}.${booking.ownerResponse ? ` ${booking.ownerResponse}` : ""}${supportLine(support)}`,
    };
  }
}

export function emailHtml(heading: string, body: string, bookingId: string) {
  return `<div style="font-family:Arial;color:#262261"><h2 style="color:#E46225">${heading}</h2><p>${body}</p><p><strong>Booking reference:</strong> ${reference(bookingId)}</p><p>Travel365</p></div>`;
}
