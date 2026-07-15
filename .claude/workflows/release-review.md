# Workflow: Release review

Run after all screen workflows are complete and merged.

## Steps

1. Final Integration Reviewer: walk the full journey (Explore -> destination ->
   stay -> booking form -> submit -> My Bookings -> booking detail -> Profile ->
   back to Explore). Verify one consistent design language, no route or auth or
   booking regressions.
2. Firebase Booking Agent: confirm a real booking still creates, notifies, and
   updates status; confirm customers see no technical errors and only their own
   bookings.
3. Responsive & Accessibility Agent: final pass at 320 and 430 px, text scale
   1.5.
4. QA Reviewer: `dart format --set-exit-if-changed .`, `flutter analyze`,
   `flutter test`; visual-quality-gate score for each primary screen.
5. Verify release readiness against root CLAUDE.md: consent, duplicate-send
   safety, role access, notification delivery evidence (not emulator-only).

## Final report

Produce the orchestrator's final report: architecture changes, UI changes,
Firebase changes, routes changed, components added, tests added, known
limitations, remaining production requirements, and a release recommendation.
