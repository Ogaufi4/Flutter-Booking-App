import {initializeApp, applicationDefault} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

// Creates/updates owner alert destinations. Usage:
// node scripts/set-company-contact.mjs [ownerWhatsApp] [ownerEmail]
const adminWhatsapp = process.argv[2] ?? "72184392";
const adminEmail = process.argv[3] ?? "owner@travel365.co.bw";

initializeApp({credential: applicationDefault(), projectId: "ecom-f0593"});
await getFirestore().collection("settings").doc("company").set(
  {adminWhatsapp, adminEmail, updatedAt: FieldValue.serverTimestamp()},
  {merge: true},
);
console.log(`settings/company set to adminWhatsapp=${adminWhatsapp} adminEmail=${adminEmail}`);
