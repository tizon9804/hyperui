# Version stamp: the running UI says which build it is

Why: after a deploy nobody — not the user, not hyperui — should guess whether the live build contains a
change. The version from the version file (`${CLAUDE_PLUGIN_ROOT}/skills/git/references/versioning.md`) is
injected at build time, shown in the UI and exposed in machine-readable form. **Add it the first time hyperui
touches a UI project that has none**; it is part of that first UI change, not a separate task. It is public
information: version, short commit, build time — never a secret, a hostname or an env value.

## 1. Build-time injection (version + short commit)

The commit comes from the host's env var — Amplify `AWS_COMMIT_ID` · Vercel `VERCEL_GIT_COMMIT_SHA` · Netlify `COMMIT_REF` ·
Cloudflare `CF_PAGES_COMMIT_SHA` (Workers Builds: `WORKERS_CI_COMMIT_SHA`) · GitHub Actions `GITHUB_SHA` — else
`git rev-parse --short HEAD` when `.git` exists at build time, else `"local"`. Short = first 7 chars. `builtAt` =
`new Date().toISOString()` at build. The version is read from the version file, never typed into the UI.

| Framework | How |
|---|---|
| Next.js | `next.config.*`: `env: { NEXT_PUBLIC_APP_VERSION: pkg.version, NEXT_PUBLIC_COMMIT: sha }` (read `package.json` with `fs`/`createRequire`); `/version.json` as `app/version.json/route.ts` returning the same values |
| Vite (React, Vue, Svelte, Solid) | `vite.config.*`: `define: { __APP_VERSION__: JSON.stringify(pkg.version), __COMMIT__: JSON.stringify(sha) }`; a small plugin with `transformIndexHtml` (the meta) and `generateBundle` → `this.emitFile({ fileName: 'version.json' })` |
| Angular | a `prebuild` script writes `src/environments/version.ts` and `public/version.json` from `package.json`; the component reads the constant |
| SvelteKit | `define` in `vite.config.*`; `src/routes/version.json/+server.ts` returns the JSON |
| Astro | `vite: { define }` in `astro.config.*`; `src/pages/version.json.ts` endpoint |
| Flutter | `package_info_plus` → `PackageInfo.fromPlatform()` `.version` / `.buildNumber` (from `pubspec.yaml`); no `version.json` (not a web origin) |
| SwiftUI / macOS | `Bundle.main.infoDictionary?["CFBundleShortVersionString"]` + `["CFBundleVersion"]` |
| Electron | `app.getVersion()` (from `package.json`), exposed to the renderer via preload |
| Tauri | `getVersion()` from `@tauri-apps/api/app` (from `tauri.conf.json`) |

## 2. Where it shows

- **Web sites**: footer, small and muted, last item: `<span class="site-version" title="Build">v1.4.2 · ab12cd3</span>`.
- **Apps** (web app, mobile, desktop): Settings → About, or the bottom of the main menu / sidebar; same format.
- Format: `v<version> · <short commit>`; without a commit, `v<version>`. Readable in production without login;
  never hover-only, never dev-only. Styled with `--muted` and `--fs-small`; no accent, no motion.

## 3. Machine-readable — both, always (web)

1. `<meta name="app-version" content="1.4.2+ab12cd3">` in the document head (SemVer build metadata after `+`).
2. `GET /version.json` → `{"version":"1.4.2","commit":"ab12cd3","builtAt":"2026-10-04T12:00:00Z"}`, generated at build
   into `public/`/`dist/` (static hosts) or served by a route handler (SSR); `Cache-Control: no-cache` where headers are yours.

`${CLAUDE_PLUGIN_ROOT}/scripts/verify-deploy.sh <url> <version>` reads them in that order, then the footer text, after a deploy
(`ship` "Verify the deploy"); the user's one-liner is `curl -s https://<domain>/version.json`.

## 4. Tests (TDD applies: red first)

- Render test that the stamp shows the version from the version file: import `package.json` (or the injected constant) and
  `expect(screen.getByTitle('Build')).toHaveTextContent(\`v${version}\`)`.
- With a `version.json` generator: one test that the emitted file (or route) returns `version` equal to the manifest's.

## 5. Rules

- The stamp reads the version file; the bump (`versioning.md`) is the only thing that moves it. Never hand-edit the string.
- Public info only. The stamp never goes behind a feature flag or an auth wall.
- Existing stamp in another place or format → keep the project's, add only the missing machine-readable parts (§3).
- Care line after adding it: `version vX.Y.Z` (it is what the user now sees in the footer).
