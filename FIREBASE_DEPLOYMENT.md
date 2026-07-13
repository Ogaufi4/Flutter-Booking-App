# Travel365 notification deployment

Firestore rules and indexes were deployed to `ecom-f0593` on June 25, 2026.

To activate approval actions, push notifications, and email:

1. Upgrade Firebase project `ecom-f0593` to Blaze: https://console.firebase.google.com/project/ecom-f0593/usage/details
2. Enable Email/Password Authentication and Cloud Messaging.
3. Install Firebase Trigger Email (`firebase/firestore-send-email`) using collection `mail`.
4. Configure Gmail SMTP as `smtps://GMAIL_ADDRESS@gmail.com:APP_PASSWORD@smtp.gmail.com:465`. Use a Google app password, never the normal password.
5. From `functions/`, run `npm install` and `npm run build`.
6. Deploy with `firebase deploy --only functions --project ecom-f0593`.
7. If desired, set `REPLY_TO_EMAIL`, `SUPPORT_PHONE`, and `SUPPORT_EMAIL` when Firebase prompts; leave `META_WHATSAPP_ENABLED=false` for the demo.
8. Authenticate Application Default Credentials, then grant the initial owner from `functions/` with `npm run set-owner -- owner@example.com`.
9. The owner must sign out and back in after the claim is assigned.

Owner notification recipients are discovered from `users` documents whose role is `owner` or `staff`; no owner address is hard-coded.

Support contact details shown inside app messages (WhatsApp/share text) are read from the Firestore document `settings/support` (fields `phone` and `email`); owners and staff can edit it from the console without an app release. Backend email/push messages use the `SUPPORT_PHONE` and `SUPPORT_EMAIL` function params for the same purpose.

Automatic Meta WhatsApp sending is intentionally disabled. The app includes manual prefilled WhatsApp chat, while `sendMetaWhatsApp` is the production adapter boundary for approved templates and secrets.