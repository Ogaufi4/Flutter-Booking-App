import {bookingFacts} from "./bookingFormat";
import type {Booking, ChannelMessage} from "../types";

export function adminAlertText(event: string, booking: Booking, bookingId: string): string {
  return [
    "Travel365 owner alert",
    event,
    ...bookingFacts(booking, bookingId).map(([label, value]) => `${label}: ${value}`),
    "Please open the owner dashboard to review.",
  ].join("\n");
}

export function customerReceiptText(message: ChannelMessage, booking: Booking, bookingId: string): string {
  const details = bookingFacts(booking, bookingId)
    .filter(([label]) => !["Customer", "Phone", "Email"].includes(label))
    .map(([label, value]) => `${label}: ${value}`)
    .join("\n");
  const body = message.receiptBody ?? `${message.body}\n\n${details}`;
  return [
    "Travel365",
    message.heading,
    body,
  ].join("\n");
}
