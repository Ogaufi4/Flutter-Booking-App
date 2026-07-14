import {existsSync, readFileSync} from "node:fs";
import {resolve} from "node:path";
import {applicationDefault, cert, initializeApp} from "firebase-admin/app";
import {getAuth} from "firebase-admin/auth";
import {getFirestore, FieldValue} from "firebase-admin/firestore";

const projectId = "ecom-f0593";
const email = process.argv[2];
const keyArgument = process.argv[3] || process.env.GOOGLE_APPLICATION_CREDENTIALS;

if (!email) {
  throw new Error(
    "Usage: npm run set-owner -- owner@example.com C:\\secure\\firebase-admin.service-account.json",
  );
}

let credential;
if (keyArgument) {
  const keyPath = resolve(keyArgument);
  if (!existsSync(keyPath)) {
    throw new Error(`Service-account key not found: ${keyPath}`);
  }
  const serviceAccount = JSON.parse(readFileSync(keyPath, "utf8"));
  if (serviceAccount.project_id !== projectId) {
    throw new Error(
      `Wrong Firebase project in key: ${serviceAccount.project_id}. Expected ${projectId}.`,
    );
  }
  credential = cert(serviceAccount);
} else {
  credential = applicationDefault();
}

initializeApp({credential, projectId});

try {
  const user = await getAuth().getUserByEmail(email);
  await getAuth().setCustomUserClaims(user.uid, {role: "owner"});
  await getFirestore().collection("users").doc(user.uid).set(
    {
      email,
      role: "owner",
      roleUpdatedAt: FieldValue.serverTimestamp(),
    },
    {merge: true},
  );
  console.log(
    `Owner access granted to ${email} (${user.uid}). Sign out and back in to refresh the token.`,
  );
} catch (error) {
  if (!keyArgument) {
    console.error(
      "No Google Application Default Credentials were found. Download a Firebase Admin service-account JSON key and pass its path as the second argument.",
    );
  }
  throw error;
}