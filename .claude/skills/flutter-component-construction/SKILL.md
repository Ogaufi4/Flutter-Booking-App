---
name: flutter-component-construction
description: Constructs reusable, accessible Travel365 Flutter widgets with clean APIs, no embedded business logic, and full state support.
---

# Use This Skill When

- building a shared widget under lib/core/widgets/
- deciding whether something should be a reusable component
- defining a component's public API
- adding loading, disabled, or empty variants to a widget

# Before Creating A Component

1. Search the repository for an existing widget that already does this
   (`lib/core/widgets/`, `lib/features/**/widgets/`). Reuse before you build.
2. Confirm it is used more than once, or is a genuine design-system pattern.
3. Confirm it takes its colors, spacing, radii, and typography from the shared
   tokens, never literals.

# Preferred Component Set

Create these only when the repository needs them and no equivalent exists:

- Travel365PrimaryButton
- Travel365SecondaryButton
- Travel365TextButton
- Travel365IconButton
- Travel365TextField
- Travel365DateField
- Travel365SearchBar
- Travel365SectionHeader
- Travel365DestinationCard
- Travel365StayCard
- Travel365AccountRow
- Travel365GuestStepper
- Travel365StatusBadge
- Travel365EmptyState
- Travel365ErrorState
- Travel365LoadingSkeleton
- Travel365BottomNavigation
- Travel365BookingOptionTile

# API Rules

- Stateless where possible; lift state to the caller.
- Required data in, callbacks out. No Firestore, no navigation service, no
  singletons reached from inside the widget.
- Every interactive widget: `onPressed`/`onTap` may be null to express disabled.
- Provide a `Semantics` label for icon-only controls.
- Respect `MediaQuery.textScaler`; never hardcode a font size that breaks at 1.5x.
- Never assume a fixed screen width. Use `Expanded`, `Flexible`, `ConstrainedBox`.

# Required Variants

Where relevant, a component supports:

- default
- loading (in-place spinner, not a layout jump)
- disabled
- pressed feedback (scale to ~0.985, 100-140 ms)
- long-label wrapping

# Button Contract

Primary buttons are 56 px high, full-width by default, deep navy, white
semibold text, radius 14-16, and include disabled and loading states. Do not
use gradients or orange for the main booking action.

# Validation

Add a widget test for each major shared component covering: renders, disabled
state, loading state, and a long label. Run `flutter analyze` and
`flutter test` before handoff.
