import {Timestamp} from "firebase-admin/firestore";
import {reference} from "../types";
import type {Booking} from "../types";

/**
 * Meta rejects a template parameter that contains a newline or tab, so the
 * layout lives in the APPROVED TEMPLATE BODY and only the values are passed
 * positionally. Submit one template (default name travel365_booking_update,
 * category Utility) whose body is exactly:
 *
 *   Travel365
 *   {{1}}
 *   Booking Ref: {{2}}
 *   Customer: {{3}}
 *   Phone: {{4}}
 *   Destination: {{5}}
 *   Travel Date: {{6}}
 *   Guests: {{7}}
 *   Please log in to the admin dashboard.
 *
 * One template covers every owner alert; {{1}} carries the event label.
 */
const oneLine = (value: unknown, fallback = "-") => {
  const text = String(value ?? "").replace(/\s+/g, " ").trim();
  return text || fallback;
};

function travelDate(booking: Booking): string {
  const raw = booking.departureDate;
  if (raw instanceof Timestamp) return raw.toDate().toISOString().slice(0, 10);
  return oneLine(raw);
}

function guests(booking: Booking): string {
  const adults = Number(booking.adults ?? 0);
  const children = Number(booking.children ?? 0);
  const total = adults + children;
  return Number.isFinite(total) && total > 0 ? String(total) : "-";
}

/** Positional body parameters for the owner alert template. */
export function adminAlertParameters(event: string, booking: Booking, bookingId: string): string[] {
  return [
    oneLine(event),
    reference(bookingId),
    oneLine(booking.fullName),
    oneLine(booking.phone),
    oneLine(booking.destination),
    travelDate(booking),
    guests(booking),
  ];
}
