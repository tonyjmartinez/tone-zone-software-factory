# tonyjmartinez.dev

Tony's personal site and GitHub profile repo. Astro 7, static output, deployed to the Cloudflare Worker
`tonyjmartinez` (`wrangler.toml`, Cloudflare's Git integration builds `dist/`).

`README.md` is shown on the GitHub profile page, so keep it a profile README, not project docs.

## Commands (run before every PR)

```sh
npm ci
npm run check   # astro check
npm run build
```

## Rules

- Shares its design system with succulents.info: Rosette components in `src/components/ui/` (import from
  `@/components/ui`), tokens in `src/styles/tokens.css`, `PlantArt` for illustrations. Keep them in sync in spirit;
  don't add a client framework.
- Accessibility first: AAA contrast in light and dark mode, real headings and landmarks, works without JavaScript.
- Must look right at 360px wide and on desktop.
- Don't invent biography facts, employers, or project claims. If content is needed, leave a clear TODO in the PR.
