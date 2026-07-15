# Travel365 notification deployment

Firestore rules and indexes were deployed to `ecom-f0593` on June 25, 2026.

To activate approval actions, push notifications, and email:

1. Upgrade Firebase project `ecom-f0593` to Blaze: https://console.firebase.google.com/project/ecom-f0593/usage/details
2. Enable Email/Password Authentication and Cloud Messaging.
3. Install Firebase Trigger Email (`firebase/firestore-send-email`) using collection `mail`.
4. Configure Gmail SMTP as `smtps://GMAIL_ADDRESS@gmail.com:APP_PASSWORD@smtp.gmail.com:465`. Use a Google app password, never the normal password.
5. Set the WaSenderAPI token with `firebase functions:secrets:set WASENDER_API_TOKEN --project ecom-f0593`.
6. From `functions/`, run `npm install` and `npm run build`.
7. Deploy with `firebase deploy --only functions --project ecom-f0593`.
8. Keep the default `WASENDER_API_URL=https://www.wasenderapi.com/api/send-message` unless WaSenderAPI changes its endpoint.
9. If desired, set `REPLY_TO_EMAIL` when Firebase prompts.
10. Authenticate Application Default Credentials, then grant the initial owner from `functions/` with `npm run set-owner -- owner@example.com`.
11. Set initial owner alert contacts with `npm run set-company-contact -- 74784067 owner@example.com`, or edit them later in the owner settings screen.
12. The owner must sign out and back in after the claim is assigned.

Owner notification email recipients are discovered from `users` documents whose role is `owner` or `staff`, plus `settings/company.adminEmail`. Owner WhatsApp alerts go to `settings/company.adminWhatsapp`, with deployment defaults only as a fallback.

Support contact details shown inside app messages are read from the Firestore document `settings/support` (fields `phone` and `email`); owners and staff can edit it from the console without an app release.

Automatic WhatsApp sending uses WaSenderAPI. Booking creation sends a WhatsApp receipt to the client phone number and a separate owner alert to `settings/company.adminWhatsapp`; customer cancellation sends an owner alert. The WaSenderAPI token must stay in Firebase Secret Manager and must never be added to Flutter, Firestore, or the repo.

Receipt delivery behavior:

- New booking: queues an email receipt for the customer, queues an email alert for the owner/staff recipients, sends a WhatsApp receipt to the customer, sends a WhatsApp alert to the owner, and pushes an in-app alert to owner/staff devices.
- Status changes to approved/declined/completed: queues a customer email and sends a customer push notification.
- Customer cancellation: queues owner/staff email, sends owner WhatsApp, and pushes owner/staff devices.
- Delivery failures are recorded in `notification_logs` and do not block booking creation.
