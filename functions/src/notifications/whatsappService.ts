import {logger} from "firebase-functions";
import {
  wasenderApiToken,
  wasenderApiUrl,
  wasenderCountryCode,
  wasenderEnabled,
} from "../config";
import {adminAlertText, customerReceiptText} from "../templates/whatsappTemplates";
import type {Booking, ChannelMessage, SendResult} from "../types";

/**
 * WaSenderAPI expects E.164. Local Botswana numbers are captured as
 * "71 234 567" or "071 234 567". Returns "" when the number cannot be trusted,
 * so a malformed number is skipped rather than delivered to the wrong recipient.
 */
export function toE164(raw: unknown): string {
  if (typeof raw !== "string") return "";
  const trimmed = raw.trim();
  const hadPlus = trimmed.startsWith("+");
  const digits = trimmed.replace(/\D/g, "");
  if (!digits) return "";
  if (hadPlus) return digits.length >= 8 ? `+${digits}` : "";
  const country = wasenderCountryCode.value().replace(/\D/g, "") || "267";
  if (digits.startsWith(country) && digits.length > country.length) return `+${digits}`;
  const local = digits.replace(/^0+/, "");
  if (!local) return "";
  return `+${country}${local}`;
}

/**
 * Sends a WhatsApp text through WaSenderAPI. The API token belongs in Firebase
 * Secret Manager, never in Flutter or Firestore.
 * Every failure path returns a SendResult rather than throwing, so a WhatsApp
 * outage can never fail a booking.
 */
async function sendText(rawTo: unknown, text: string, bookingId: string, label: string): Promise<SendResult> {
  if (!wasenderEnabled.value()) {
    return {sent: false, recipient: "", error: "WASENDER_ENABLED is false"};
  }

  const token = wasenderApiToken.value();
  if (!token) {
    return {sent: false, recipient: "", error: "WASENDER_API_TOKEN is not configured"};
  }

  const to = toE164(rawTo);
  if (!to) {
    return {sent: false, recipient: String(rawTo ?? ""), error: `${label} WhatsApp number is missing or not usable`};
  }

  const payload = {to, text};

  try {
    const response = await fetch(wasenderApiUrl.value(), {
      method: "POST",
      headers: {"Authorization": `Bearer ${token}`, "Content-Type": "application/json"},
      body: JSON.stringify(payload),
    });
    const result = await response.json() as {
      success?: boolean;
      data?: {msgId?: string | number};
      message?: string;
      error?: {message?: string} | string;
    };
    if (!response.ok) {
      const error = typeof result.error === "string" ? result.error : result.error?.message ?? result.message ?? `HTTP ${response.status}`;
      logger.error("WaSenderAPI send failed", {bookingId, label, to, error});
      return {sent: false, recipient: to, error};
    }
    if (result.success === false) {
      const error = typeof result.error === "string" ? result.error : result.error?.message ?? result.message ?? "WaSenderAPI returned success=false";
      logger.error("WaSenderAPI rejected message", {bookingId, label, to, error});
      return {sent: false, recipient: to, error};
    }
    return {sent: true, recipient: to, messageId: String(result.data?.msgId ?? "")};
  } catch (error) {
    logger.error("WaSenderAPI request threw", {bookingId, label, to, error: String(error)});
    return {sent: false, recipient: to, error: String(error)};
  }
}

export const sendCustomerBookingReceipt = (
  booking: Booking,
  bookingId: string,
  message: ChannelMessage,
): Promise<SendResult> => sendText(
  booking.phone,
  customerReceiptText(message, booking, bookingId),
  bookingId,
  "customer",
);

export const sendOwnerBookingAlert = (
  event: string,
  booking: Booking,
  bookingId: string,
  adminWhatsapp: string,
): Promise<SendResult> => sendText(
  adminWhatsapp,
  adminAlertText(event, booking, bookingId),
  bookingId,
  "owner",
);
