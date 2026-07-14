# Travel365 Claude Guide

Use this repository as the source of truth for Travel365 work.

## Operating rules

- Keep the app visually clean, white-first, and aligned to the Travel365 brand colors.
- Treat the Firestore booking collection as the authoritative workflow state.
- Keep customer, owner, and staff roles distinct and enforced at the data layer.
- Use Firebase for auth, Firestore, push notifications, email queues, and backend orchestration.
- Use WhatsApp only as a safe demo/share path unless production sending is explicitly enabled and verified.
- Request notification permission before registering a device token.
- Keep customer and owner contact details editable only through the intended profile or settings flow.

## Source map

- `lib/` for Flutter UI, booking forms, dashboards, and profile flows
- `functions/` for backend booking events, push notifications, email queueing, and idempotency
- `firestore.rules` and `firestore.indexes.json` for access control and query support
- `.claude/skills/` for the Travel365 Claude skill docs

## Travel365 workflow

1. Customer signs in or verifies phone number.
2. App registers the device token only after notification permission is granted.
3. Customer creates a booking document in Firestore.
4. Backend sends booking acknowledgment to the customer and alert to owner/staff.
5. Owner/staff review the booking and update status with audit fields.
6. Backend notifies the customer of approval, decline, completion, or cancellation.
7. QA verifies consent, duplicate-send safety, role access, and release readiness.

## Review standard

- Prefer exact field names and actual status values over vague descriptions.
- Update schema, UI, rules, and backend together whenever booking or notification behavior changes.
- Do not assume delivery succeeded unless Firestore, Functions, or FCM evidence confirms it.
- For anything involving OTP, notifications, or email/WhatsApp delivery, verify the device, permissions, and backend path separately.
- Treat emulator-only success as insufficient for release decisions when push notifications or device permissions are involved.

## Decision standard

- If a change affects data shape, access control, or message delivery, validate all three layers: UI, rules, backend.
- If a flow can retry, make it idempotent.
- If a flow can fail silently, log or persist the failure path.
