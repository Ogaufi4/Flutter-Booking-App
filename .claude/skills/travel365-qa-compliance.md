# Travel365 QA Compliance

Use this skill for release checks, consent handling, notification delivery, duplicate-send safety, and backend readiness for Travel365.

## Scope

- Release verification
- Consent and permission checks
- Notification/email/WhatsApp safety
- Duplicate-send and idempotency checks
- Backend readiness checks

## Inputs

- A build, deploy, or release candidate
- A new booking or notification flow
- A consent or permission change
- A backend or rules change

## Outputs

- Pass/fail release status
- Identified risk areas
- Clear remediation notes
- Proof of backend and device-path behavior

## Acceptance checks

- Notification permission is requested clearly and only when needed.
- FCM token registration succeeds on a real device or properly configured Play Services emulator.
- Token refresh updates the stored device record.
- Booking creation succeeds even if push or email delivery fails.
- Duplicate backend execution does not create duplicate alerts or duplicate mail queue records.
- Email, push, and WhatsApp text are branded, accurate, and consistent.
- WhatsApp sharing is clearly presented as sharing/manual sending unless production API sending is enabled.
- Owner and customer contact settings are editable through the intended profile/settings path.
- Approval, decline, and cancellation events preserve server timestamps and actor IDs.

## Release readiness

- Rules are deployed and match the app behavior.
- Indexes support the live queries in booking lists and dashboards.
- Functions compile cleanly.
- Secrets are configured in Firebase or deployment settings, not in the repository.
- Any login, OTP, or notification error is traceable with a clear root cause.
- A release is not acceptable if it only works on a debug emulator and cannot be validated on a real device path.

## Safety checks

- Validate consent before sending OTP, push, or alert messages.
- Verify that no private data is exposed to the wrong role.
- Confirm the app does not claim delivery success unless the backend actually acknowledged it.
- Confirm that owner approval fields cannot be spoofed from the client.

## Non-goals

- Do not approve a release based on emulator-only notification testing.
- Do not treat partial backend wiring as production-ready.
