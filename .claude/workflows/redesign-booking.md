# Workflow: Redesign the Booking form (Book a trip)

Precondition: design system and shared components approved.

Target files (proposed ownership): `lib/features/bookings/pages/book_trip_screen.dart`,
`lib/features/bookings/**` presentation only. The booking repository and schema
are owned by the Firebase Booking Agent.

## Steps

1. Repository Auditor: map the current form fields, validation, and the
   `createBooking` payload. No edits.
2. Luxury UI Designer: spec the form layout - grouping, field order, date-field
   stacking breakpoint, single primary submit button, states.
3. Firebase Booking Agent: confirm the submitted document shape still satisfies
   firestore.rules (status `new`, `ownerResponse` `''`, `declineReason` `''`,
   `userId == auth.uid`). Guard against duplicate submit.
4. Screen Implementation Agent: rebuild the form with shared components; disable
   submit while sending; show loading and customer-safe errors.
5. Responsive & Accessibility Agent: keyboard does not cover submit; fields
   readable at 1.5x; date fields stack below ~350 px.
6. QA Reviewer: analyze, test, submit a real booking end to end, score.

## Done when

A booking still writes correctly to Firestore, no raw errors reach the customer,
and the screen passes the quality gate.
