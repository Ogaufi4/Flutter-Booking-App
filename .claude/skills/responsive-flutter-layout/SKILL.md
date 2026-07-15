---
name: responsive-flutter-layout
description: Builds responsive Travel365 Flutter layouts with correct mobile proportions and no fixed mockup-based dimensions.
---

# Rules

- Design for constraints, not screenshots.
- Use SafeArea around system UI.
- Use LayoutBuilder for local width decisions.
- Use MediaQuery only for screen-level decisions.
- Use AspectRatio for repeatable image proportions.
- Use ConstrainedBox for sensible maximum dimensions.
- Use Expanded and Flexible for rows.
- Stack date fields vertically below the supported width.
- Never use a fixed width equal to a mockup width.
- Test at 320 logical pixels.
- Test with long text and text scaling.

# Example Decision

```dart
final stackDateFields = constraints.maxWidth < 350;
```

The breakpoint must be selected because the fields can no longer maintain readable content and 44 px touch targets, not because a specific device model was copied.
