# Travel365 Firebase

Use this skill when the work touches Firebase Auth, Firestore, Cloud Functions, notification delivery, email queues, indexes, secrets, or deployment readiness for Travel365.

## Scope

- Firebase Auth and role claims
- Firestore schema, rules, and indexes
- Cloud Functions for booking events and notifications
- Secret/configuration handling
- Deploy and release readiness

## Inputs

- Booking schema or status changes
- Firestore rule changes
- Notification/email workflow changes
- Firebase deployment errors

## Outputs

- Deployable rules and functions
- Verified query indexes
- Backend-owned audit fields and event records
- Clear notes on what is deployed vs pending

## Production rules

- Treat Firebase as the system of record for booking data, device tokens, notification events, and user roles.
- Keep Firestore rules, indexes, and Flutter queries aligned. If one changes, re-check the others.
- Keep Cloud Functions as the trusted backend boundary for:
  - booking status changes,
  - push notification fan-out,
  - email queue creation,
  - duplicate-send protection.
- Never place SMTP credentials, FCM server secrets, Meta tokens, or admin keys inside Flutter code or committed source.
- Prefer server timestamps and backend-written audit fields over client-written approval fields.
- Preserve role separation:
  - customer: read/write own profile and own bookings only,
  - owner/staff: manage bookings and read operational data,
  - public/guest: no private booking access.
- Prefer deterministic document IDs, timestamp fields written by the backend, and idempotent event records for anything that can be retried.

## Travel365 data expectations

- Bookings must keep a stable schema for:
  - `userId`
  - `fullName`
  - `email`
  - `phone`
  - `destination`
  - `status`
  - `createdAt`
  - `updatedAt`
- Status flow must stay consistent across app, rules, and backend:
  - `new`
  - `reviewing`
  - `approved`
  - `declined`
  - `completed`
  - `cancelled`
- Legacy `submitted` data should continue to be treated as `new`.
- Audit fields such as `approvedAt`, `declinedAt`, `cancelledAt`, and `statusUpdatedAt` should be backend-owned whenever possible.
- Booking documents should never require the client to write approval timestamps or role-controlled state without backend validation.

## Delivery rules

- Push notifications must be triggered by backend events, not by the client as the source of truth.
- Email should be queued or sent from backend code, not assembled in Flutter.
- WhatsApp should remain a safe share/manual flow unless a production Meta Cloud API integration is explicitly enabled and verified.
- Duplicate delivery attempts must be guarded with deterministic event IDs or equivalent idempotency.
- If a delivery channel fails, persist the failure for diagnostics and continue the booking workflow.

## Release checks

- Confirm rules deploy successfully.
- Confirm indexes support the live queries used by booking lists and dashboards.
- Confirm functions compile and deploy for the target Firebase project.
- Confirm secrets are configured in Firebase, not in code.
- Confirm failed email/push delivery does not block booking creation or status updates.
- Confirm any new query has a matching index before release.

## Non-goals

- Do not store secrets in Flutter or committed source.
- Do not let the client be the source of truth for approval or notification delivery.
