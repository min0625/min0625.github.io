# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with
code in this repository.

## Overview

Personal portfolio site for Min Huang (黃彥閔), Backend Engineer in Taipei.
Single page, vanilla HTML/CSS — no framework, no bundler.

Owner contact and profile links: [references.md](./references.md).
For work history, fetch https://www.cake.me/resumes/min0625 at runtime.

## Commands

```bash
bun run check   # Biome lint + format check — this is what CI runs on PRs
bun run fix     # auto-fix lint + format
bun run build   # clean → copy index.html + public/* to dist/ → inject build meta
bun run preview # build, then serve dist/ on http://localhost:3000
```

Run `bun run fix`, then confirm `bun run check` is clean, after touching any
JSON config or `scripts/*.js`. Neither command inspects `index.html` (see
Conventions), so HTML/CSS edits are verified by eye via `bun run preview`.
There is no test suite.

## Architecture

`index.html` is the entire site: inline `<style>` (design tokens → reset →
utilities → per-section components → responsive rules last), then the markup
for nav / `#hero` / `#about` / `#skills` / `#experience` / `#contact` / footer,
plus one `<script type="application/ld+json">` Person block for SEO. There is
no executable JavaScript on the page — keep it that way; effects are CSS-only.

`scripts/inject-build-info.js` runs at build time only. It inserts
`build-time` / `build-git-hash` meta tags before `</head>` in `dist/index.html`
and never modifies the source file.

`public/*` is copied flat into `dist/`, so asset URLs are root-relative
(`/favicon.ico`, `/og-image.png`). They break when opening `index.html` from
the filesystem — use `bun run preview` to check anything asset-related.

Deploy: push to `main` triggers `.github/workflows/build-and-deploy.yml`, which
publishes `dist/` to GitHub Pages. `wrangler.jsonc` serves the same `dist/` as
Cloudflare static assets. Canonical host is https://min0625.com.

## Design System

"Kinetic Logic", specified in [DESIGN.md](./DESIGN.md) — consult it before
adding any visual element. The invariants that are easiest to break:

- Corners are strictly **0px** — no `border-radius` anywhere
- Depth comes from tonal layering only — no `box-shadow`
- Accent `#3b82f6` only on interactive elements and highlights, used sparingly
- `JetBrains Mono` for headings/UI/labels; `Hanken Grotesk` for body copy
- The custom properties in `:root` are the single source of truth — never
  hard-code a color or spacing value that has a `--var` equivalent

## Responsive

Two breakpoints are in use: `max-width: 768px` (nav wraps to a second row,
grids collapse to one column) and `max-width: 600px` (tighter section padding).
Verify changes at both ≥1024px and ≤390px.

`section { scroll-margin-top }` inside the 768px query is hand-tuned to the
wrapped nav's height — retune it if the nav layout changes.

Keep touch targets ≥44×44px, body text ≥16px on mobile (iOS auto-zoom), and no
page-level horizontal overflow at any width (`body { overflow-x: hidden }`).
The `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
tag must stay in `<head>`.

## Conventions

Biome does **not** process HTML — `bun run fix` and `bun run check` skip
`index.html` entirely and only cover the JSON/JSONC files and
`scripts/inject-build-info.js`. Formatting the site is therefore manual: match
the surrounding markup, keep 2-space indent and an 80-char line width, and give
long elements one attribute per line (see the `<meta>` tags in `index.html`).
Biome's single-quote / semicolon rules apply to `scripts/*.js` only.
