import {initializeApp, applicationDefault} from "firebase-admin/app";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

// Creates/updates the editable support contact shown in app WhatsApp/share
// messages. Usage: node scripts/set-support-contact.mjs [phone] [email]
const phone = process.argv[2] ?? "+267 71 000 000";
const email = process.argv[3] ?? "support@travel365.co.bw";

initializeApp({credential: applicationDefault(), projectId: "ecom-f0593"});
await getFirestore().collection("settings").doc("support").set(
  {phone, email, updatedAt: FieldValue.serverTimestamp()},
  {merge: true},
);
console.log(`settings/support set to phone=${phone} email=${email}`);
