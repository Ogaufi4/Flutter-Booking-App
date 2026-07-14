import {logger} from "firebase-functions";
import {
  metaAccessToken,
  metaCountryCode,
  metaEnabled,
  metaPhoneNumberId,
  metaTemplate,
  metaTemplateLanguage,
} from "../config";
import {adminAlertParameters} from "../templates/whatsappTemplates";
import type {Booking, SendResult} from "../types";

/**
 * Meta only accepts E.164. Local numbers are captured as "71 234 567" or
 * "071 234 567". Returns "" when the number cannot be trusted, so a malformed
 * number is skipped rather than delivered to the wrong recipient.
 */
export function toE164(raw: unknown): string {
  if (typeof raw !== "string") return "";
  const trimmed = raw.trim();
  const hadPlus = trimmed.startsWith("+");
  const digits = trimmed.replace(/\D/g, "");
  if (!digits) return "";
  if (hadPlus) return digits.length >= 8 ? digits : "";
  const country = metaCountryCode.value().replace(/\D/g, "");
  if (digits.startsWith(country) && digits.length > country.length) return digits;
  const local = digits.replace(/^0+/, "");
  if (!local) return "";
  return `${country}${local}`;
}

/**
 * Sends the owner/admin booking alert through the Meta WhatsApp Cloud API.
 * Customers never receive WhatsApp -- they are notified by email and push.
 * Every failure path returns a SendResult rather than throwing, so a WhatsApp
 * outage can never fail a booking.
 */
export async function sendBookingAlert(
  event: string,
  booking: Booking,
  bookingId: string,
  adminWhatsapp: string,
): Promise<SendResult> {
  if (!metaEnabled.value()) {
    return {sent: false, recipient: "", error: "META_WHATSAPP_ENABLED is false"};
  }

  const phoneNumberId = metaPhoneNumberId.value();
  const token = metaAccessToken.value();
  if (!phoneNumberId || !token) {
    return {sent: false, recipient: "", error: "META_PHONE_NUMBER_ID or META_ACCESS_TOKEN is not configured"};
  }

  const to = toE164(adminWhatsapp);
  if (!to) {
    return {sent: false, recipient: String(adminWhatsapp ?? ""), error: "settings/company.adminWhatsapp is missing or not a usable number"};
  }

  const payload = {
    messaging_product: "whatsapp",
    to,
    type: "template",
    template: {
      name: metaTemplate.value(),
      language: {code: metaTemplateLanguage.value()},
      components: [{
        type: "body",
        parameters: adminAlertParameters(event, booking, bookingId).map((text) => ({type: "text", text})),
      }],
    },
  };

  try {
    const response = await fetch(`https://graph.facebook.com/v21.0/${phoneNumberId}/messages`, {
      method: "POST",
      headers: {"Authorization": `Bearer ${token}`, "Content-Type": "application/json"},
      body: JSON.stringify(payload),
    });
    const result = await response.json() as {messages?: {id: string}[]; error?: {message?: string}};
    if (!response.ok) {
      const error = result.error?.message ?? `HTTP ${response.status}`;
      logger.error("WhatsApp send failed", {bookingId, event, to, error});
      return {sent: false, recipient: to, error};
    }
    return {sent: true, recipient: to, messageId: result.messages?.[0]?.id ?? ""};
  } catch (error) {
    logger.error("WhatsApp request threw", {bookingId, event, to, error: String(error)});
    return {sent: false, recipient: to, error: String(error)};
  }
}
