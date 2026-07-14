import {initializeApp} from "firebase-admin/app";
import {getFirestore} from "firebase-admin/firestore";
import {defineBoolean, defineSecret, defineString} from "firebase-functions/params";
import {setGlobalOptions} from "firebase-functions/v2";

initializeApp();
setGlobalOptions({region: "us-central1", maxInstances: 10});

export const db = getFirestore();

export const replyToEmail = defineString("REPLY_TO_EMAIL", {default: ""});

// Fallback owner alert number, used only when settings/company.adminWhatsapp is
// blank. The owner can override it from Settings in the app without a redeploy.
export const defaultAdminWhatsapp = defineString("DEFAULT_ADMIN_WHATSAPP", {default: "72425104"});

export const metaEnabled = defineBoolean("META_WHATSAPP_ENABLED", {default: false});
export const metaPhoneNumberId = defineString("META_PHONE_NUMBER_ID", {default: ""});
export const metaTemplate = defineString("META_TEMPLATE_NAME", {default: "travel365_booking_update"});
export const metaTemplateLanguage = defineString("META_TEMPLATE_LANGUAGE", {default: "en"});
// Botswana. Numbers are captured locally ("71 234 567") and the Graph API only
// accepts E.164.
export const metaCountryCode = defineString("META_COUNTRY_CODE", {default: "267"});
// Secret Manager, never .env and never the repo.
export const metaAccessToken = defineSecret("META_ACCESS_TOKEN");
