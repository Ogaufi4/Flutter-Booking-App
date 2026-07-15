# Travel365 Claude Code Instructions

## Project Objective

Transform Travel365 into a premium, restrained, luxury travel-booking application while preserving its existing booking logic, Firebase integrations, navigation, authentication, and business requirements.

The interface must feel:

- calm
- editorial
- luxurious
- spacious
- trustworthy
- simple
- conversion-focused

The application must not become visually decorative, crowded, or overly animated.

## Core Design Direction

Use:

- off-white page backgrounds
- deep navy primary actions
- restrained warm-orange accents
- large, high-quality travel photography
- serif typography for editorial headings
- sans-serif typography for controls and body content
- subtle borders
- minimal shadows
- generous empty space
- consistent component dimensions
- calm transitions

Avoid:

- excessive gradients
- excessive orange
- strong Material shadows
- random radii
- many card containers
- tiny typography
- decorative gold everywhere
- oversized controls
- raw Firebase error messages
- duplicated components
- business logic inside presentation widgets

## Required Design Tokens

The following values are the source of truth:

```dart
background: Color(0xFFFAF9F6)
surface: Color(0xFFFFFFFF)
primary: Color(0xFF111827)
primarySoft: Color(0xFF1F2937)
accent: Color(0xFFC98224)
accentSoft: Color(0xFFF8EFE3)
textPrimary: Color(0xFF18181B)
textSecondary: Color(0xFF71717A)
textMuted: Color(0xFFA1A1AA)
border: Color(0xFFE7E5E4)
divider: Color(0xFFF0EFEC)
success: Color(0xFF2E7D5B)
successSoft: Color(0xFFEAF6EF)
error: Color(0xFFC84A4A)
```

These are implemented in `lib/core/theme/app_colors.dart`. Do not redefine them elsewhere.

## Required Dimensions

```text
Screen horizontal padding: 20-24
Primary button height: 56
Standard field height: 56
Minimum tap target: 44
Input radius: 14
Button radius: 14-16
Card radius: 18-20
Hero image radius: 22-24
Section spacing: 32-48
Major hero spacing: 48-64
```

## Mandatory Agent Workflow

Every significant feature must pass through:

1. Repository Auditor
2. Design System Architect
3. Screen or Component Engineer
4. Responsive and Accessibility Agent
5. QA Reviewer
6. Final Integration Reviewer

No screen agent may create new design tokens independently.

No screen agent may add a duplicate reusable component without first searching the repository.

No UI agent may modify Firestore rules or booking schemas unless explicitly assigned.

No Firebase agent may redesign visual components beyond applying existing shared components.

## Definition of Done

A feature is complete only when:

- it compiles
- static analysis passes
- there are no overflow errors
- loading, empty, populated, and error states exist
- raw technical errors are hidden from customers
- the layout works between 320 and 430 logical pixels
- tap targets are at least 44 x 44
- typography comes from the shared design system
- colors come from shared tokens
- existing booking and authentication behavior still works
- screenshots are reviewed against the luxury design criteria

## Relationship to the root CLAUDE.md

The repository root `CLAUDE.md` remains the source of truth for Travel365
backend, Firestore, and notification rules. This file governs the luxury
redesign. When both apply, follow both; if they ever conflict, stop and ask.
