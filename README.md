# min0625.github.io

Personal portfolio site for Min Huang (黃彥閔). Live at **https://min0625.github.io**.

See [AGENTS.md](./AGENTS.md) for project guidelines, [references.md](./references.md) for
owner profile, and [DESIGN.md](./DESIGN.md) for the Kinetic Logic design system spec.

## Quick Start

```bash
# Install dev tooling (Biome linter/formatter via Bun)
bun install

# Lint + format check
bun run check

# Auto-fix lint + format issues
bun run fix

# Build the site to dist/
bun run build

# Preview the built site locally
bun run preview
```

Open `index.html` directly in a browser, or use `bun run preview` for a local built preview.

## Project Structure

```
index.html      # All markup, CSS, and content (single source of truth)
DESIGN.md       # Kinetic Logic design system spec
AGENTS.md       # Project guidelines for AI agents / contributors
references.md   # Owner contact & profile references
biome.json      # Biome linter/formatter config
package.json    # Bun scripts
```
