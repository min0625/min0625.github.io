---
name: Kinetic Logic
colors:
  surface: '#121414'
  surface-dim: '#121414'
  surface-bright: '#383939'
  surface-container-lowest: '#0d0e0f'
  surface-container-low: '#1a1c1c'
  surface-container: '#1e2020'
  surface-container-high: '#292a2a'
  surface-container-highest: '#343535'
  on-surface: '#e3e2e2'
  on-surface-variant: '#c2c6d6'
  inverse-surface: '#e3e2e2'
  inverse-on-surface: '#2f3131'
  outline: '#8c909f'
  outline-variant: '#424754'
  surface-tint: '#adc6ff'
  primary: '#adc6ff'
  on-primary: '#002e6a'
  primary-container: '#4d8eff'
  on-primary-container: '#00285d'
  inverse-primary: '#005ac2'
  secondary: '#c8c6c5'
  on-secondary: '#313030'
  secondary-container: '#474746'
  on-secondary-container: '#b7b5b4'
  tertiary: '#ffb786'
  on-tertiary: '#502400'
  tertiary-container: '#df7412'
  on-tertiary-container: '#461f00'
  error: '#ffb4ab'
  on-error: '#690005'
  error-container: '#93000a'
  on-error-container: '#ffdad6'
  primary-fixed: '#d8e2ff'
  primary-fixed-dim: '#adc6ff'
  on-primary-fixed: '#001a42'
  on-primary-fixed-variant: '#004395'
  secondary-fixed: '#e5e2e1'
  secondary-fixed-dim: '#c8c6c5'
  on-secondary-fixed: '#1c1b1b'
  on-secondary-fixed-variant: '#474746'
  tertiary-fixed: '#ffdcc6'
  tertiary-fixed-dim: '#ffb786'
  on-tertiary-fixed: '#311400'
  on-tertiary-fixed-variant: '#723600'
  background: '#121414'
  on-background: '#e3e2e2'
  surface-variant: '#343535'
  background-pure: '#000000'
  background-elevated: '#0a0a0a'
  text-primary: '#f0f0f0'
  text-muted: '#a0a0a0'
  border-subtle: '#1a1a1a'
  accent-electric: '#3b82f6'
typography:
  headline-xl:
    fontFamily: JetBrains Mono
    fontSize: 48px
    fontWeight: '700'
    lineHeight: '1.1'
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: JetBrains Mono
    fontSize: 32px
    fontWeight: '600'
    lineHeight: '1.2'
  headline-lg-mobile:
    fontFamily: JetBrains Mono
    fontSize: 24px
    fontWeight: '600'
    lineHeight: '1.2'
  body-lg:
    fontFamily: Hanken Grotesk
    fontSize: 18px
    fontWeight: '400'
    lineHeight: '1.6'
  body-md:
    fontFamily: Hanken Grotesk
    fontSize: 16px
    fontWeight: '400'
    lineHeight: '1.5'
  code-sm:
    fontFamily: JetBrains Mono
    fontSize: 14px
    fontWeight: '400'
    lineHeight: '1.5'
  label-caps:
    fontFamily: JetBrains Mono
    fontSize: 12px
    fontWeight: '700'
    lineHeight: '1.0'
    letterSpacing: 0.1em
spacing:
  base: 4px
  gutter: 24px
  margin-mobile: 16px
  margin-desktop: 64px
  max-width: 1200px
---

## Brand & Style

This design system is built for the high-performance software engineer portfolio. It draws inspiration from cutting-edge AI labs, emphasizing technical precision, speed, and clarity. The brand personality is "Advanced Intellectualism"—it is quiet, confident, and utilitarian.

The visual style is **Minimalist-Technic**. It rejects unnecessary ornamentation in favor of high-contrast information density. By leveraging a deep black environment, the design system minimizes eye strain and creates a focused workspace for showcasing complex projects. The aesthetic is defined by sharp edges, thin lines, and an uncompromising commitment to the "code" aesthetic, ensuring the developer’s work remains the focal point.

## Colors

The palette is anchored in a "True Black" (#000000) foundation to maximize contrast and visual impact on modern displays.

- **Primary:** The electric blue is used exclusively for interactive triggers, progress indicators, and syntax highlights. It should be used sparingly to maintain the minimalist ethos.
- **Surface Tiers:** Use #0a0a0a for secondary containers and #1a1a1a for tertiary elements or thin borders.
- **Typography:** Headlines and primary content use #f0f0f0 (Off-white) to prevent the harsh "vibration" of pure white on black, while secondary metadata uses #a0a0a0.

## Typography

This system uses a dual-font strategy to balance technical utility with readability.

- **Headlines & UI Elements:** JetBrains Mono is used for all structural elements, titles, and data points. This reinforces the developer-centric nature of the portfolio.
- **Body Content:** Hanken Grotesk provides a clean, neutral sans-serif counterpoint for long-form project descriptions, ensuring high legibility without distracting from the code aesthetic.
- **Scalability:** Larger headlines should utilize negative letter spacing to maintain a "tight" technical feel. Labels and small metadata should always be rendered in JetBrains Mono, often in uppercase, to evoke terminal-style interfaces.

## Layout & Spacing

The layout follows a **Fixed Grid** philosophy on desktop and a **Fluid Fluid** model on mobile.

- **Desktop:** 12-column grid with a 1200px maximum width. Elements are aligned to a strict 4px baseline grid to ensure mathematical precision in spacing.
- **Margins:** Large, generous margins (64px+) are used to isolate content blocks, creating an "archival" or "gallery" feel for project case studies.
- **Reflow:** On mobile, margins shrink to 16px, and multi-column grids collapse into a single vertical stack. Navigation moves from a horizontal top bar to a simplified sticky header.

## Elevation & Depth

In this design system, depth is communicated through **Tonal Layering** and **High-Contrast Outlines** rather than shadows.

- **Surfaces:** There are no soft drop shadows. Differentiation between layers is achieved by moving from #000000 (base) to #0a0a0a (raised).
- **Borders:** Use 1px solid borders in #1a1a1a to define card boundaries or section breaks.
- **Interactivity:** Active states are signaled by switching a border color from #1a1a1a to the primary electric blue (#3b82f6) or by a slight scale increase (1.02x).

## Shapes

The shape language is strictly **Sharp (0px)**. All containers, buttons, input fields, and images must have 90-degree corners. This uncompromising geometric approach reinforces the "technical/code" narrative and differentiates the design from the rounded, soft aesthetics common in consumer SaaS.

## Components

- **Monospace Buttons:** Primary buttons feature a solid #3b82f6 background with black text. Secondary buttons use a 1px white border with no fill. All buttons use JetBrains Mono and should include a "hover" state that shifts the background color or adds a "chevron" icon (e.g., `BUTTON_TEXT ->`).
- **Input Fields:** Minimalist design consisting of a 1px bottom border only. On focus, the border color transitions to electric blue.
- **Chips/Tags:** Used for tech stacks. Small, monospace text inside a 1px border. No background fill unless active.
- **Sticky Navigation:** A slim, 60px height bar with a backdrop blur (if transparency is used) or a solid #000000 fill. Use a simple horizontal list of monospace links.
- **Project Cards:** Large, sharp-edged containers. Images within cards should have a slight desaturation or "darken" overlay, which clears on hover to reveal full color.
- **Code Snippets:** Use a custom-styled block with #0a0a0a background and syntax highlighting based on the electric blue and muted gray palette.
