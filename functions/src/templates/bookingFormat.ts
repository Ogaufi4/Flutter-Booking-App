import {Timestamp} from "firebase-admin/firestore";
import {reference} from "../types";
import type {Booking, SupportContact} from "../types";
import {supportLine} from "../settings";

export const oneLine = (value: unknown, fallback = "-") => {
  const text = String(value ?? "").replace(/\s+/g, " ").trim();
  return text || fallback;
};

const serviceLabels: Record<string, string> = {
  custom_trip: "Complete trip",
  flight_only: "Flight only",
  flight: "Flight",
  hotel_stay: "Hotel stay",
  accommodation: "Hotel or lodge",
  car_rental: "Car rental",
  holiday_package: "Holiday package",
  corporate_travel: "Corporate travel",
  group_travel: "Group travel",
  tour: "Tour or activity",
  insurance: "Travel insurance",
  visa_assistance: "Visa assistance",
};

export function serviceLabel(booking: Booking): string {
  const raw = oneLine(booking.serviceType, "custom_trip");
  return serviceLabels[raw] ?? raw.replace(/_/g, " ");
}

export function formatDate(value: unknown): string {
  if (value instanceof Timestamp) return value.toDate().toISOString().slice(0, 10);
  if (value instanceof Date) return value.toISOString().slice(0, 10);
  if (typeof value === "string") {
    const parsed = new Date(value);
    if (!Number.isNaN(parsed.getTime())) return parsed.toISOString().slice(0, 10);
    return oneLine(value);
  }
  if (value && typeof value === "object" && "toDate" in value) {
    const maybeDate = (value as {toDate?: () => Date}).toDate?.();
    if (maybeDate instanceof Date && !Number.isNaN(maybeDate.getTime())) {
      return maybeDate.toISOString().slice(0, 10);
    }
  }
  return "-";
}

export function travellers(booking: Booking): string {
  const adults = Number(booking.adults ?? 0);
  const children = Number(booking.children ?? 0);
  const adultText = Number.isFinite(adults) ? `${adults} adult${adults === 1 ? "" : "s"}` : "0 adults";
  const childText = Number.isFinite(children) ? `${children} child${children === 1 ? "" : "ren"}` : "0 children";
  return `${adultText}, ${childText}`;
}

export function statusLabel(status: unknown): string {
  return oneLine(status, "new").replace(/_/g, " ");
}

export function bookingFacts(booking: Booking, bookingId: string): Array<[string, string]> {
  return [
    ["Booking reference", reference(bookingId)],
    ["Status", statusLabel(booking.status)],
    ["Service", serviceLabel(booking)],
    ["Destination", oneLine(booking.destination)],
    ["Departure city", oneLine(booking.departureCity)],
    ["Departure date", formatDate(booking.departureDate)],
    ["Return date", formatDate(booking.returnDate)],
    ["Travellers", travellers(booking)],
    ["Customer", oneLine(booking.fullName)],
    ["Phone", oneLine(booking.phone)],
    ["Email", oneLine(booking.email)],
  ];
}

export function customerReceiptBody(
  intro: string,
  booking: Booking,
  bookingId: string,
  support: SupportContact,
): string {
  const details = bookingFacts(booking, bookingId)
    .filter(([label]) => !["Customer", "Phone", "Email"].includes(label))
    .map(([label, value]) => `${label}: ${value}`)
    .join("\n");
  const supportText = supportLine(support).trim();
  return `${intro}\n\n${details}${supportText ? `\n${supportText}` : ""}`;
}

export function ownerReceiptBody(intro: string, booking: Booking, bookingId: string): string {
  const details = bookingFacts(booking, bookingId)
    .map(([label, value]) => `${label}: ${value}`)
    .join("\n");
  return `${intro}\n\n${details}`;
}
