---
name: ui-state-handling
description: Ensures every Travel365 data-backed screen supports polished loading, empty, populated, and error states.
---

# Required States

## Loading

Use skeletons matching the eventual layout.

Avoid a large spinner in the center of an otherwise empty page.

## Empty

Explain the situation without blaming the customer.

Provide one clear next action.

## Error

Use:

- short heading
- human-readable explanation
- retry action
- optional support path

Do not display stack traces, Firebase exceptions, rule names, or internal codes.

## Populated

Preserve the same spacing and layout structure as loading skeletons to prevent visual jumps.
