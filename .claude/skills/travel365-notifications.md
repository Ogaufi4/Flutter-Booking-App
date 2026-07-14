# Travel365 Notifications

Use this skill when the work involves push notifications, booking receipts, email alerts, WhatsApp sharing, OTP verification, or editable contact details for Travel365.

## Scope

- Push notification registration and display
- Booking receipt email content and delivery
- WhatsApp share/manual flows
- OTP verification flows
- Editable contact details for owner and customer

## Inputs

- A booking event or status change
- A notification permission request
- An OTP/auth flow change
- A contact detail update request

## Outputs

- Correct device registration behavior
- Consistent push/email/WhatsApp copy
- Clear fallback behavior when a delivery path is unavailable
- Verified tap navigation to the booking or relevant screen

## Production rules

- Request notification permission before registering or refreshing an FCM token.
- Store tokens per device, not as a single token per user, so multiple devices can receive alerts.
- Use Firebase Cloud Messaging for pop-up alerts on Android and keep foreground handling consistent with local notifications.
- Keep backend delivery as the source of truth for booking confirmations and status changes.
- Send email from backend code only. Do not generate or send receipts from Flutter.
- Keep WhatsApp as a safe demo/share flow unless a production Meta Cloud API path has been approved, configured, and tested.
- Allow both owner and customer contact details to be editable in the appropriate settings/profile source, but do not let the client overwrite backend-owned notification audit fields.
- Notification code must distinguish between:
  - device registration,
  - foreground display,
  - background delivery,
  - tap navigation,
  - backend send result.

## Message content rules

- Every customer-facing alert should preserve:
  - booking reference,
  - destination,
  - current status,
  - support contact details.
- Notification copy should stay branded and consistent across push, email, and WhatsApp.
- Notification taps should route to the correct booking or booking detail screen.
- OTP flows must be treated as authentication/security flows, not just UI messaging.
- OTP must never be presented as a booking confirmation message.

## Delivery expectations

- New booking:
  - customer gets acknowledgment,
  - owner/staff get booking alert.
- Approval, decline, completion:
  - customer gets the status update.
- Cancellation:
  - owner/staff get the cancellation alert.
- If a channel is unavailable, the app should still surface the most appropriate supported channel and log the failure path separately.

## Safety rules

- If push, email, or WhatsApp fails, booking creation must still succeed.
- Prevent duplicate sends with backend idempotency or event records.
- Do not claim WhatsApp was auto-sent unless the production API really sent it.
- Do not depend on emulator behavior as proof of production push delivery.

## Non-goals

- Do not treat OTP as a booking alert.
- Do not send mail from Flutter UI code.
