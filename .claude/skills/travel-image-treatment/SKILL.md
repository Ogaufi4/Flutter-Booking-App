---
name: travel-image-treatment
description: Handles travel photography in Travel365 - aspect ratios, loading, failure, and framing that makes destinations feel premium.
---

# Use This Skill When

- placing a hero or destination image
- building a card that features photography
- deciding image aspect ratio, radius, or fallback

# Proportions

- Hero image: bounded height via `AspectRatio` (about 4:5 to 3:2), radius 22-24.
- Horizontal destination card image: consistent ratio across the row (e.g. 3:2),
  radius 18-20.
- Never derive dimensions from mockup pixels. Use `AspectRatio`, `LayoutBuilder`,
  `ConstrainedBox`.

# Loading And Failure

- Fade the image in over 180-250 ms once loaded; do not pop.
- While loading, show a neutral placeholder in `AppColors.divider`, matching the
  final frame size, so the layout does not shift.
- On failure, show a calm placeholder (soft background + muted icon), never a
  broken-image glyph or an error string.
- Use a caching image loader where the project already provides one; do not add a
  new dependency without approval.

# Framing

- Use `BoxFit.cover` so the frame is always filled; center the focal area.
- A subtle bottom-up dark scrim is allowed only when text sits on the image, and
  only as far as legibility requires. No decorative gradients.
- Keep image corners aligned with the design system: cards 18-20, hero imagery
  22-24, and small thumbnails only as rounded as their surrounding component.
- Do not crop images so tightly that the destination, hotel room, or travel
  product becomes hard to inspect.

# Accessibility And Semantics

- Provide meaningful semantic labels for destination, stay, or activity images
  when the image communicates content.
- Mark purely decorative images as excluded from semantics.
- Ensure text laid over images remains readable at text scale 1.5.

# Brand Note

Placeholder/sample imagery is fine during redesign, but real, licensed, high
quality destination photography is what sells the premium feel. Flag any
screen still shipping placeholder art before release.
