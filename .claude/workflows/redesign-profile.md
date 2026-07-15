# Workflow: Redesign Profile

Precondition: design system and shared components approved.

Target files (proposed ownership): `lib/features/profile/**`. The owner variant
(`lib/features/owner/pages/owner_main_screen.dart` profile tab) shares the same
component language and should be kept visually consistent.

## Steps

1. Repository Auditor: map profile data sources (auth user, editable contact
   fields) and existing profile widgets. No edits.
2. Luxury UI Designer: spec the header, account rows, and settings entry points;
   restrained accent, generous spacing, one clear primary action if any.
3. Screen Implementation Agent: rebuild using shared `AccountRow` / card
   components and tokens; keep contact edits routed only through the intended
   settings flow (per root CLAUDE.md).
4. Firebase Booking Agent (if profile edits write to Firestore): confirm writes
   respect the users rules and role checks.
5. Responsive & Accessibility Agent: verify widths, text scales, tap targets.
6. QA Reviewer: analyze, test, score.

## Done when

Customer and owner profile read as one product, edits stay in the intended flow,
and the screen passes the gate.
