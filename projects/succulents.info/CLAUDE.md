# succulents.info

Plain-language succulent care site. Astro 7, static output, deployed to Cloudflare Workers static assets.
The README is the full guide to where things live; read it before larger changes.

## Commands (run before every PR)

```sh
npm ci
npm run check   # astro check (types) + vitest (contrast + plant finder tests)
npm run build   # static site in dist/
```

CI (`.github/workflows/deploy.yml`, "Check and deploy") runs the same and gives each same-repo PR a Cloudflare preview URL.

## Rules

- Content: one plant per file in `src/content/plants/*.md`; schemas in `src/content.config.ts` fail the build on
  missing fields. `art`/`form` values come from `src/data/taxonomy.ts`.
- UI: use the Rosette components from `@/components/ui`. A new component goes in `src/components/ui/`, its CSS in
  `src/styles/ui.css`, its export in `index.ts`, and a `<Specimen>` on `src/pages/design-system.astro`.
- Accessibility is a feature, not a nicety: WCAG AAA (7:1) contrast in light and dark mode (the tests enforce it),
  status never color-only, everything works without JavaScript, respect reduced motion.
- Must work at 360px wide and on desktop.
- Plain-language copy: short sentences, no jargon without a glossary entry.
- No client framework. Small progressive-enhancement scripts only.
