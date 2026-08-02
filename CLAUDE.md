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

Run `bun run fix`, then confirm `bun run check` is clean, after any edit —
`index.html` included. `check` covers HTML syntax and formatting but not
semantics or rendering, so visual changes still need `bun run preview`.
There is no test suite.

## Architecture

`index.html` is the entire site. `<head>` holds the meta / OG block, the inline
`<style>` (design tokens → reset → utilities → per-section components →
responsive rules last), and one `<script type="application/ld+json">` Person
block for SEO. `<body>` is `nav` → `main` (`#hero` / `#about` / `#skills` /
`#experience` / `#contact`) → `footer`. There is no executable JavaScript on
the page — keep it that way; effects are CSS-only.

`scripts/inject-build-info.js` runs at build time only. It inserts
`build-time` / `build-git-hash` meta tags before `</head>` in `dist/index.html`
and never modifies the source file.

`public/*` is copied flat into `dist/`, so asset URLs are root-relative
(`/favicon.ico`, `/og-image.jpg`). They break when opening `index.html` from
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

`--nav-h` is the measured height of the sticky nav (60px desktop, 119px once
the nav wraps to two rows). It drives both `#hero` sizing and
`section { scroll-margin-top }`, so changing the nav layout means re-measuring
that one variable and nothing else.

Keep touch targets ≥44×44px, body text ≥16px on mobile (iOS auto-zoom), and no
page-level horizontal overflow at any width (`body { overflow-x: hidden }`).
The `<meta name="viewport" content="width=device-width, initial-scale=1.0">`
tag must stay in `<head>`.

## Conventions

Biome formats `index.html` (`html.formatter.enabled` in `biome.json`) and its
HTML parser rejects structural errors such as an unclosed tag, so `bun run
check` guards both. Still write markup in the house style — 2-space indent,
80-char lines, one attribute per line on long elements — so `fix` stays a
no-op instead of reflowing your diff. Inline `<style>` contents are formatted
too; `indentScriptAndStyle` is left off, matching the existing indentation.

Biome ships **no** HTML lint rules, so nothing automated checks semantics or
accessibility. The current baseline is 0 axe-core violations against
WCAG 2.0/2.1/2.2 A+AA — re-audit externally after any markup change.

Biome's single-quote / semicolon rules apply to `scripts/*.js` only.
