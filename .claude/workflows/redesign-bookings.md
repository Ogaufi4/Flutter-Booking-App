# Workflow: Redesign My Bookings (booking list)

Precondition: design system and shared components approved.

Target files (proposed ownership): `lib/features/bookings/**` list presentation,
`lib/features/trips/**` if that is the customer trip list.

## Steps

1. Repository Auditor: identify the query that lists the signed-in customer's
   bookings and the status values rendered. No edits.
2. Luxury UI Designer: spec the list - card rhythm, status badge treatment,
   spacing, and the four states (loading skeletons, empty, populated, error).
3. Firebase Booking Agent: confirm the query is scoped to `userId == auth.uid`
   and maps Firestore docs to a domain model; map failures to customer-safe copy.
4. Screen Implementation Agent: build the list with shared `StatusBadge`,
   `EmptyState`, `ErrorState`, and loading skeletons that match the populated
   layout.
5. Responsive & Accessibility Agent: verify across widths and text scales.
6. QA Reviewer: analyze, test, verify empty and error states render without
   technical strings; score.

## Done when

The list shows all four states cleanly, respects ownership, and passes the gate.
