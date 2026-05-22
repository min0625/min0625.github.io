# Project Guidelines

## Overview

Personal portfolio site for Min Huang (黃彥閔), a Senior Backend Engineer based in Taipei, Taiwan.
Single-page, vanilla HTML/CSS — no JavaScript framework, no build step, no bundler.

## Owner

See [references.md](./references.md) for the full contact and profile list.
For detailed background and work history, fetch https://www.cake.me/resumes/min0625 at runtime.

## Build & Check

```bash
bun run check   # lint + format check (Biome)
bun run fix     # auto-fix lint + format issues
bun run build   # generate dist/ output for deployment
bun run preview # run local preview server
```

Run `bun run fix` after any HTML/CSS edit, then confirm `bun run check` passes with no errors.

## Architecture

All content lives in a single file: `index.html`. It contains:
- All CSS (inline `<style>`) — design tokens → reset → component styles
- All HTML markup (nav, #hero, #about, #skills, #experience, #contact sections)
- No external JS dependencies; no `<script>` blocks

## Design System

The design system "Kinetic Logic" is defined in [DESIGN.md](./DESIGN.md). Always consult it before adding new visual elements. Key invariants:

- **Shape:** All corners are strictly **0px** (no border-radius anywhere)
- **Dark theme:** Base is `#000000`; surface tiers via CSS custom properties (see `:root` in `index.html`)
- **Accent:** Electric blue `#3b82f6` only for interactive elements and highlights — use sparingly
- **Fonts:** `JetBrains Mono` for headings/UI/labels; `Hanken Grotesk` for body copy
- **Depth:** Tonal layering only — no box-shadows

CSS custom properties are the single source of truth for tokens; never hard-code color or spacing values that have a `--var` equivalent.

## Mobile Experience

The site must be fully usable on mobile devices. Key requirements:

- **Responsive layout:** Use `@media (max-width: 768px)` breakpoints; all sections must reflow gracefully on small screens
- **Touch targets:** Interactive elements (links, buttons) must be at least 44×44px tap area
- **Typography:** Body text minimum `16px` on mobile to prevent auto-zoom on iOS; headings should scale down via `clamp()` or media queries
- **Navigation:** The nav must collapse or adapt on small screens — no horizontal overflow
- **No horizontal scroll:** `overflow-x: hidden` on `body`; no element should cause page-level overflow on any viewport width
- **Viewport meta:** Ensure `<meta name="viewport" content="width=device-width, initial-scale=1">` is present

Always verify new sections/components on both desktop (≥1024px) and mobile (≤390px) viewports.

## Biome Conventions

- Single quotes, 2-space indent, 80-char line width
- `bun run fix` will auto-correct most style issues
- HTML formatting is handled by Biome; keep attributes on separate lines for long elements (see existing `<meta>` tags as examples)
