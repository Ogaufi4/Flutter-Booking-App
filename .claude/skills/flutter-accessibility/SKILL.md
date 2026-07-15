---
name: flutter-accessibility
description: Ensures Travel365 screens are usable with screen readers, large text, and adequate tap targets, without harming the luxury layout.
---

# Use This Skill When

- finishing any screen before QA
- adding icon-only buttons
- laying out forms and controls
- choosing colors for text on a background

# Requirements

- Tap targets at least 44 x 44 logical pixels, even when the visual is smaller
  (expand the hit area, not necessarily the paint).
- Every icon-only control has a `Semantics` label describing the action.
- Text remains readable and unclipped at text scale 1.3 and 1.5. Prefer wrapping
  over truncation for headings; truncate only labels that can afford it.
- Color is never the only signal. Status uses a label or icon in addition to
  color (e.g. a status badge with text, not just a colored dot).
- Contrast: body text on `background`/`surface` must stay legible; avoid
  `textMuted` for essential reading content.
- Form fields have visible labels, not placeholder-only labels.
- Focus and keyboard: the keyboard must not cover the active field or the submit
  button; use scroll padding / `SafeArea`.

# Screen-State Accessibility

- Loading skeletons should not announce meaningless placeholder text.
- Empty and error states must include a clear heading and one actionable next
  step where appropriate.
- Booking status labels must be readable as text, not inferred from color.
- Customer-facing errors must not include Firestore, rules, stack trace, or
  permission jargon.

# Verify

- Walk the screen with TalkBack/VoiceOver reasoning: can each control be
  identified and activated?
- Re-check at 320 px width with text scale 1.5 for overflow.
- Confirm every repeated row or card has a sensible reading order: title,
  supporting detail, status/price/date, then actions.
