import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {defineBoolean, defineSecret, defineString} from "firebase-functions/params";
import {setGlobalOptions} from "firebase-functions/v2";

initializeApp();
setGlobalOptions({region: "us-central1", maxInstances: 10});

export const db = getFirestore();

export const replyToEmail = defineString("REPLY_TO_EMAIL", {default: ""});

// Fallback owner alert destinations, used only when the matching
// settings/company field is blank. The owner overrides either from Settings in
// the app, with no redeploy.
export const defaultAdminWhatsapp = defineString("DEFAULT_ADMIN_WHATSAPP", {default: "72425104"});
export const defaultAdminEmail = defineString("DEFAULT_ADMIN_EMAIL", {default: "travel@travel365.co.bw"});

export const metaEnabled = defineBoolean("META_WHATSAPP_ENABLED", {default: false});
export const metaPhoneNumberId = defineString("META_PHONE_NUMBER_ID", {default: ""});
export const metaTemplate = defineString("META_TEMPLATE_NAME", {default: "travel365_booking_update"});
export const metaTemplateLanguage = defineString("META_TEMPLATE_LANGUAGE", {default: "en"});
// Botswana. Numbers are captured locally ("71 234 567") and the Graph API only
// accepts E.164.
export const metaCountryCode = defineString("META_COUNTRY_CODE", {default: "267"});
// Secret Manager, never .env and never the repo.
export const metaAccessToken = defineSecret("META_ACCESS_TOKEN");
