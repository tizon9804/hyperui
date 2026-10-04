# Deploy recipes

**Snapshot 2026-10-03.** For each host: fit, build command, env vars, connect-repo steps, custom
domain steps. **The first deploy is run by the user** — the skill writes the config file and the
exact command or clicks, then stops (REQ-012). Commands below are the documented CLIs; confirm the
flag on the linked docs page before handing them over, and never add `--prod`/`deploy` to a
command the skill itself executes.

Common to every host:
- Build output and command come from the framework: Next.js `next build` → `.next`; Astro
  `astro build` → `dist`; Vite/React/Angular `npm run build` → `dist` (Angular: `dist/<app>/browser`);
  SvelteKit via adapter. Put them in `package.json` scripts so the host's auto-detect works.
- Env vars: the skill writes `.env.example` (names + comments, no values) and lists which are
  public (`NEXT_PUBLIC_*`, `VITE_*`, `PUBLIC_*`) vs server-only. Values go into the host's secret
  store **by the user**; never into the repo.
- Preview deploys on PRs are on by default on Vercel, Netlify, Cloudflare (Workers Builds),
  Amplify and Render; use them for the first look before touching production.
- Rollback: every host keeps previous deployments; "promote previous" is the undo button.

## 1. Cloudflare Workers (default for $0 commercial, edge SSR, static)

- **Fit**: static sites and SSR frameworks with a Workers adapter (Astro, SvelteKit, Remix,
  Next via OpenNext); APIs; anything that must be free *and* commercial. Cloudflare says to
  start new projects on Workers, not Pages.
- **Config**: `wrangler.jsonc` (or `wrangler.toml`) with `name`, `main` or `assets.directory`,
  `compatibility_date`. Framework guides: https://developers.cloudflare.com/workers/framework-guides/
- **Build**: the framework's build; static assets served from `assets.directory`.
- **Env**: public values under `vars` in `wrangler.jsonc`; secrets with `npx wrangler secret put NAME`
  (prompts for the value; run by the user) or Dashboard → Worker → Settings → Variables and Secrets.
- **Connect repo**: Dashboard → Workers & Pages → Create → Import a repository → pick repo → build
  command + deploy command → Save. Workers Builds then deploys on push.
  https://developers.cloudflare.com/workers/ci-cd/builds/
- **First deploy (user runs)**: `npx wrangler login` then `npx wrangler deploy`. Output gives
  `https://<name>.<account>.workers.dev`.
- **Custom domain**: Workers & Pages → Worker → Settings → Domains & Routes → Add → Custom Domain →
  `example.com` (zone must be on Cloudflare DNS, no existing CNAME on that hostname; Cloudflare
  creates the DNS records and certificate). Or in `wrangler.jsonc`: `routes: [{ pattern: "example.com", custom_domain: true }]`.
  https://developers.cloudflare.com/workers/configuration/routing/custom-domains/
- Pricing: https://developers.cloudflare.com/workers/platform/pricing/ · MCP: `claude mcp add --transport http cloudflare https://mcp.cloudflare.com/mcp`

## 2. Vercel (default for Next.js when the budget allows Pro or the use is non-commercial)

- **Fit**: Next.js first-class, any framework via zero-config detection. **Hobby is non-commercial.**
- **Config**: none needed for detected frameworks; optional `vercel.json` for redirects/headers.
- **Build**: auto-detected (`next build`); override in Project → Settings → Build and Deployment.
- **Env**: Project → Settings → Environment Variables (per Production/Preview/Development), or
  `vercel env add NAME production` (prompts; user runs). Pull locally with `vercel env pull`.
  https://vercel.com/docs/environment-variables
- **Connect repo**: vercel.com → Add New → Project → Import Git Repository → pick repo → Deploy.
  Every push to the default branch deploys production; every PR gets a preview URL.
- **First deploy (user runs)**: the Import flow above, or `npx vercel` (preview) then
  `npx vercel --prod`. https://vercel.com/docs/cli/deploy
- **Custom domain**: Project → Settings → Domains → Add Domain → apex gets an **A** record
  (`76.76.21.21` or the card's value), subdomains a per-project **CNAME**; TXT only if another
  Vercel account already uses the domain; certificate automatic. Hobby: 50 domains per project. https://vercel.com/docs/domains/working-with-domains/add-a-domain
- Pricing: https://vercel.com/pricing · MCP: `claude mcp add --transport http vercel https://mcp.vercel.com`

## 3. Netlify (static / SPA / light functions, non-tech friendly)

- **Fit**: Astro, Angular, React/Vite SPAs, forms, light serverless functions.
- **Config**: `netlify.toml` with `[build] command = "npm run build"` and `publish = "dist"`;
  SPA redirect `/* /index.html 200` in `_redirects` or the toml.
  https://docs.netlify.com/build/configure-builds/file-based-configuration/
- **Env**: Site → Site configuration → Environment variables, or `netlify env:set NAME value`
  (user runs; value never in the repo). https://docs.netlify.com/build/environment-variables/overview/
- **Connect repo**: app.netlify.com → Add new project → Import an existing project → pick repo →
  confirm build command and publish directory → Deploy.
- **First deploy (user runs)**: the Import flow, or `npx netlify-cli login`, `npx netlify-cli init`,
  then `npx netlify-cli deploy --prod`. https://docs.netlify.com/cli/get-started/
- **Custom domain**: Domain management → Add a domain → either Netlify DNS or external DNS (A to
  the load balancer IP shown, CNAME `www` → `<site>.netlify.app`); HTTPS auto via Let's Encrypt.
  https://docs.netlify.com/manage/domains/configure-domains/
- Pricing: https://www.netlify.com/pricing/ · MCP: `claude mcp add --transport http netlify https://netlify-mcp.netlify.app/mcp`

## 4. AWS Amplify Hosting (teams already on AWS)

- **Fit**: Next.js / Angular / React with AWS backends (Cognito, AppSync, DynamoDB); CI built in.
- **Config**: `amplify.yml` build spec (`preBuild: npm ci`, `build: npm run build`,
  `artifacts.baseDirectory: .next` or `dist`). https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html
- **Env**: Amplify console → App → Hosting → Environment variables; secrets via Secrets (SSM) for
  server-side use. https://docs.aws.amazon.com/amplify/latest/userguide/environment-variables.html
- **Connect repo**: AWS console → Amplify → Create new app → GitHub (authorize) → pick repo and
  branch → review build settings → Save and deploy. Branch pushes auto-deploy.
- **First deploy (user runs)**: the console flow above (Amplify builds in AWS; no local deploy
  command needed).
- **Custom domain**: App → Hosting → Custom domains → Add domain → Route 53 domains auto-configure;
  external DNS gets a CNAME for verification + CNAME/ANAME for the app; certificate via ACM, free.
  https://docs.aws.amazon.com/amplify/latest/userguide/custom-domains.html
- Pricing: https://aws.amazon.com/amplify/pricing/ · MCP: AWS MCP Server `claude mcp add --transport http aws-mcp https://aws-mcp.us-east-1.api.aws/mcp`

## 5. Firebase Hosting / App Hosting (mobile-first teams, Google stack)

- **Fit**: static + SPA on Hosting (Spark free); Next.js/Angular SSR on App Hosting (**Blaze only**).
- **Config**: `firebase.json` with `hosting.public: "dist"` and SPA rewrite to `/index.html`;
  App Hosting uses `apphosting.yaml`. https://firebase.google.com/docs/hosting/full-config
- **Env**: Hosting is static (public env baked at build). App Hosting: `apphosting.yaml` `env:` with
  secrets in Cloud Secret Manager via `firebase apphosting:secrets:set NAME` (user runs).
  https://firebase.google.com/docs/app-hosting/configure
- **Connect repo**: Firebase console → App Hosting → Get started → connect GitHub → pick repo/branch
  → rollout on push. Classic Hosting deploys from CI or the CLI.
- **First deploy (user runs)**: `npx firebase-tools login`, `npx firebase-tools init hosting`, then
  `npx firebase-tools deploy --only hosting`. https://firebase.google.com/docs/hosting/quickstart
- **Custom domain**: Hosting → Add custom domain → TXT verification → A records shown → wait for
  the certificate (auto). https://firebase.google.com/docs/hosting/custom-domain
- Pricing: https://firebase.google.com/pricing · MCP: `claude mcp add firebase -- npx -y firebase-tools@latest mcp`

## 6. Render (full-stack services, Docker, cron, managed Postgres)

- **Fit**: a Node/Python/Go web service + background worker + Postgres from one dashboard; Docker.
  Free web services sleep after 15 min; **free Postgres expires at 30 days**.
- **Config**: optional `render.yaml` Blueprint (services, env groups, databases).
  https://render.com/docs/blueprint-spec
- **Build**: Build Command `npm ci && npm run build`, Start Command `npm start` (or Dockerfile).
- **Env**: Service → Environment → Add variable / Secret files; Environment Groups shared across
  services. https://render.com/docs/configure-environment-variables
- **Connect repo**: dashboard.render.com → New → Web Service → connect GitHub → pick repo → runtime,
  build and start commands → instance type → Create Web Service. Auto-deploys on push.
- **First deploy (user runs)**: the Create Web Service flow (Render builds on its side).
- **Custom domain**: Service → Settings → Custom Domains → + Add Custom Domain → follow the
  provider-specific records shown (CNAME to `<service>.onrender.com` for subdomains); remove any
  `AAAA` records; TLS automatic, HTTP redirected to HTTPS. https://render.com/docs/custom-domains
- Pricing: https://render.com/pricing · MCP: `/add-plugin render` in Claude Code (https://render.com/docs/mcp-server)

## 7. Railway (zero-config full-stack + databases, monorepos)

- **Fit**: services + Postgres/Redis/MySQL provisioned in clicks; Nixpacks or Dockerfile builds.
  Free plan is a $1/mo credit; always-on apps land on Hobby $5/mo.
- **Config**: optional `railway.json` / `railway.toml` (build and deploy commands, healthcheck).
  https://docs.railway.com/reference/config-as-code
- **Env**: Service → Variables (reference other services with `${{Postgres.DATABASE_URL}}`), or
  `railway variables --set NAME=value` (user runs). https://docs.railway.com/guides/variables
- **Connect repo**: railway.com → New Project → Deploy from GitHub repo → pick repo → add a
  database from the same canvas → Generate Domain for a `*.up.railway.app` URL.
- **First deploy (user runs)**: the GitHub flow, or `npm i -g @railway/cli`, `railway login`,
  `railway init`, then `railway up`. https://docs.railway.com/guides/cli
- **Custom domain**: Service → Settings → Networking → Public Networking → Custom Domain → add
  **both** the CNAME and the TXT record Railway shows; TLS automatic. https://docs.railway.com/guides/public-networking#custom-domains
- Pricing: https://railway.com/pricing · MCP: `railway setup agent --oauth` (https://docs.railway.com/reference/mcp-server)

## 8. After every deploy: verify the live version (the skill runs this — SKILL.md §7)

```bash
"${CLAUDE_PLUGIN_ROOT}/scripts/verify-deploy.sh" https://<domain> <x.y.z>         # polls 30 s × 10 min; exit 0 = live
"${CLAUDE_PLUGIN_ROOT}/scripts/verify-deploy.sh" https://<domain> <x.y.z> --once  # single check
curl -s https://<domain>/version.json                                             # the user's own one-liner
```

Order of truth: `/version.json` → `<meta name="app-version">` → the `v<x.y.z>` footer text (`skills/design/references/version-stamp.md`).
Expected version = the version file after the bump (`skills/git/references/versioning.md`). The result line goes to `.hyperui/ship.md`
`## Deploys`. Still the old version after 10 min → the host built an older commit or the build failed: read the build log
(Vercel: Deployments → the deployment → Build Logs · Netlify: Deploys → the deploy · Cloudflare: Workers & Pages → Deployments ·
Amplify: App → the build → Build logs); never redeploy yourself. No version at all → the site has no stamp yet: add it, redeploy.

## 9. After the first deploy (checklist items the skill ticks with the user)

1. Production URL opens over HTTPS; `www` and root redirect to one canonical host.
2. Env vars present in production (a missing one is the most common first-deploy failure — read
   the build log the user pastes).
3. Health check: an uptime monitor on `/` or `/health` (host-native, or a free external one).
4. Error alerts: the host's log drain or an error tracker; the skill wires the SDK, the user adds the DSN.
5. `decisions.md` has the host pick with its pricing URL; `profile.md` has `providers.host`.

## Sources

Cloudflare: https://developers.cloudflare.com/workers/framework-guides/ · https://developers.cloudflare.com/workers/ci-cd/builds/ · https://developers.cloudflare.com/workers/configuration/routing/custom-domains/ · https://developers.cloudflare.com/workers/platform/pricing/
Vercel: https://vercel.com/docs/cli/deploy · https://vercel.com/docs/environment-variables · https://vercel.com/docs/domains/working-with-domains/add-a-domain · https://vercel.com/docs/limits/fair-use-guidelines
Netlify: https://docs.netlify.com/cli/get-started/ · https://docs.netlify.com/build/configure-builds/file-based-configuration/ · https://docs.netlify.com/manage/domains/configure-domains/
Amplify: https://docs.aws.amazon.com/amplify/latest/userguide/build-settings.html · https://docs.aws.amazon.com/amplify/latest/userguide/custom-domains.html
Firebase: https://firebase.google.com/docs/hosting/quickstart · https://firebase.google.com/docs/hosting/custom-domain · https://firebase.google.com/docs/app-hosting/configure
Render: https://render.com/docs/blueprint-spec · https://render.com/docs/custom-domains · https://render.com/docs/free
Railway: https://docs.railway.com/guides/cli · https://docs.railway.com/reference/config-as-code · https://docs.railway.com/guides/public-networking
