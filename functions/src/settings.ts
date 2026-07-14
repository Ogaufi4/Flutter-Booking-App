import {db, defaultAdminEmail, defaultAdminWhatsapp} from "./config";
import type {CompanySettings, SupportContact} from "./types";

const text = (value: unknown) => (typeof value === "string" ? value.trim() : "");

/**
 * settings/support -- the contact customers SEE in their notifications.
 * Owner-editable in the app, so it is read per event rather than baked into
 * deploy config. A missing or blank field yields no support line at all, never
 * a placeholder number.
 */
export async function supportContact(): Promise<SupportContact> {
  const snapshot = await db.collection("settings").doc("support").get();
  return {phone: text(snapshot.get("phone")), email: text(snapshot.get("email"))};
}

/**
 * settings/company -- where owner/admin alerts are SENT. Owner-editable in the
 * app, so it is read per event rather than baked into deploy config. A blank
 * field falls back to DEFAULT_ADMIN_WHATSAPP / DEFAULT_ADMIN_EMAIL, so alerts
 * still reach the owner before anyone has opened the settings screen.
 */
export async function companySettings(): Promise<CompanySettings> {
  const snapshot = await db.collection("settings").doc("company").get();
  return {
    agencyName: text(snapshot.get("agencyName")) || "Travel365",
    adminEmail: text(snapshot.get("adminEmail")) || defaultAdminEmail.value().trim(),
    adminWhatsapp: text(snapshot.get("adminWhatsapp")) || defaultAdminWhatsapp.value().trim(),
  };
}

export function supportLine(support: SupportContact) {
  const channels = [];
  if (support.phone) channels.push(`call ${support.phone}`);
  if (support.email) channels.push(`email ${support.email}`);
  return channels.length ? ` Questions? Please ${channels.join(" or ")}.` : "";
}
