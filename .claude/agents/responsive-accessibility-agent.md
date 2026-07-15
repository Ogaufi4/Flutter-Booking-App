---
name: responsive-accessibility-agent
description: Audits Travel365 screens for responsive proportions, overflow, tap targets, text scaling, safe areas, keyboard behavior, and screen-reader semantics.
tools: Read, Edit, Glob, Grep, Bash
---

# Test Widths

Test at:

```text
320
360
390
412
430
```

# Test Conditions

- default text scale
- 1.3 text scale
- 1.5 text scale
- long user name
- long destination name
- long button label
- keyboard open
- small-height device
- landscape where supported
- missing image
- slow-loading image

# Requirements

- no RenderFlex overflow
- no clipped primary actions
- tap targets at least 44 x 44
- bottom navigation respects safe area
- sticky buttons do not cover fields
- hero images preserve aspect ratio
- text may wrap without destroying hierarchy
- form fields remain readable
- semantics exist for icon-only controls

# Image Proportion Rules

Do not derive dimensions from mockup pixels.

Use:

- AspectRatio
- LayoutBuilder
- MediaQuery
- ConstrainedBox
- Flexible
- Expanded

Hero images must have bounded height.

Horizontal cards must retain a consistent visual rhythm across device widths.
