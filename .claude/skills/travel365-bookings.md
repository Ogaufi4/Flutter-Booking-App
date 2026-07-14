# Travel365 Bookings

Use this skill for booking forms, my bookings screens, booking detail views, owner/staff dashboards, approval actions, and booking status transitions.

## Scope

- Booking create/edit/view flows
- Booking status transitions
- Owner/staff review actions
- My bookings and dashboard surfaces
- Firestore schema alignment

## Inputs

- Booking form requirements
- Status flow changes
- Dashboard or booking list layout changes
- Firestore rule or repository updates

## Outputs

- Accurate booking form and detail UX
- Consistent status behavior across app and backend
- Clear ownership and role enforcement
- Reusable booking data for receipts and alerts

## Production rules

- Customer booking access must be limited to the authenticated owner of the document.
- Owner/staff actions should be available only where they belong: booking detail or dashboard review surfaces.
- Keep the booking status model identical across:
  - Flutter UI labels,
  - Firestore documents,
  - Firestore rules,
  - Cloud Functions,
  - notifications.
- Treat legacy `submitted` bookings as `new` everywhere.
- Keep write permissions narrow:
  - customers create and cancel only their own eligible bookings,
  - owner/staff update management fields only,
  - backend writes audit timestamps and notification side effects.

## Booking schema expectations

- Booking forms should capture at minimum:
  - destination,
  - dates,
  - travellers,
  - service type,
  - full name,
  - email,
  - phone,
  - notes if needed.
- Booking forms should validate required fields before save and use friendly, specific errors.
- Booking details should present:
  - booking reference,
  - route or destination,
  - travel dates,
  - traveller count,
  - service type,
  - status,
  - owner response or decline reason when applicable.
- Booking lists should make the current status obvious without requiring a tap.

## Editing guidance

- Update schema, rules, repository, and UI together.
- Reuse the same booking fields for receipts, notifications, and owner review views.
- Make status changes explicit and auditable; do not silently mutate approval data from the client.
- If the owner can edit a booking status, the client must still respect the server-side state on refresh.

## Non-goals

- Do not let booking status logic drift between UI and Firestore rules.
- Do not allow client-side approval timestamps or role escalation.
