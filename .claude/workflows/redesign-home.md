# Workflow: Redesign the Explore / Home screen

Precondition: the design system and shared components have passed QA.

Target files (proposed ownership): `lib/features/home/**`,
`lib/features/explore/**`.

## Steps

1. Repository Auditor: confirm current Home/Explore structure, route, and data
   source. No edits.
2. Luxury UI Designer: produce the layout spec (focal point, image ratios,
   section order, spacing, button hierarchy, empty/loading/error states).
3. Screen Implementation Agent: build the screen from that spec using only
   shared components and tokens. One clear primary action.
4. Responsive & Accessibility Agent: verify 320-430 px, text scale 1.3/1.5, tap
   targets, safe areas.
5. Firebase Booking Agent: confirm any destination/booking entry points still
   reach the real data and route correctly.
6. QA Reviewer: run `flutter analyze` + `flutter test`; score against
   visual-quality-gate.
7. Final Integration Reviewer (deferred until other screens land).

## Done when

Matches the CLAUDE.md Definition of Done and scores >= 42/50 on the visual
quality gate.
