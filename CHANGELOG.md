# Changelog

All notable changes to hyperui. Format: Keep a Changelog; versions follow SemVer.

## 0.7.0 — 2026-10-03
- **Explicit next-step choices after every unit of work.** Root `SKILL.md` §9 is now "Close the turn with a choice": when the next step is the user's decision, the turn ends with a choice prompt — the `AskUserQuestion` tool when the session has it (one question, 2–4 options, the recommended one first and marked "(Recommended)", its built-in "Other" for free text), otherwise the same options as a numbered list ending with "or tell me what to change", always the last thing in the reply, with `state.md` `open:` recording the pending choice. Options in the user's language; the chosen one goes to `state.md` `next:`. Never just "done".
- `build`: after a task → continue with task N+1 (Recommended) · do all remaining tasks without stopping (one report at the end; still stops for a blocking review finding or a risky action) · fix or change something in task N · stop. After the last task → review everything · ship it · add another feature · stop.
- `spec`: every gate is a choice — approve and continue (Recommended) · change something in this phase · skip ahead / switch to SDD-lite (`dev`/`senior` only); the artifact link line is unchanged.
- `design`: the pick is a choice of the 2–3 direction names (recommended first) · mix / adjust a direction · show me 2 more.
- `review`: proposed fixes on the user's code → apply all (Recommended) · only the blocking ones · show me the diff first · skip.
- `templates/hyperui/state.md` documents `next:` as the chosen option and `open:` `pending choice:`. README "How it works" gains the bullet.

## 0.6.0 — 2026-10-03
- **Every spec file is shown as a Claude artifact.** After writing any spec markdown (`00-prd.md`, `01-requirements.md`, `02-design.md`, `03-tasks.md`, `01-bug-analysis.md`, or the SDD-lite `<topic>.md`) the `spec` specialist publishes it in the same turn as a readable page (`skills/spec/references/spec-page-template.html`: design tokens, dark mode, sticky table of contents, tables, checklists, Mermaid via jsdelivr, print stylesheet) with the Artifact tool — one artifact per file, republished to the same url on every revision, the link next to the gate question. When the full track passes the tasks gate it also publishes a consolidated `Spec: <Topic>` page (header card, TOC, the four sections, merged traceability table), republished whenever a section changes; the SDD-lite artifact is already the consolidated document. No Artifact tool in the session (headless `-p`, evals) → the same HTML goes to `.hyperui/spec/<topic>/index.html` or `.hyperui/spec/<topic>.html` and the path is given. Urls recorded in `state.md` under `artifacts:` and in each spec file's frontmatter (`artifact_url`). Conventions in `skills/spec/references/spec-artifacts.md`; `templates/hyperui/state.md` gains the `artifacts:` block. Gates unchanged: one approval per phase.

## 0.5.0 — 2026-10-03
- **Motion AI Kit in `/hyperui:setup`:** new step after the Motion npm package installs the official kit (MIT, https://motion.dev/docs/ai-kit) the way `npx motion-ai` does for Claude Code (that installer is interactive-only): `npm pack motion-ai@latest`, then `content/skills/motion` → `.claude/skills/motion` and `content/agents/motion-reviewer.md` → `.claude/agents/` (project, or `~` with `--global`), and registers the hosted `motion` MCP (`https://mcp.motion.dev`, docs + example search) at local scope (user with `--global`). Idempotent; `--skip-motion-kit` skips it; `--motion-plus` also registers `motion-plus` (`https://mcp.motion.dev/plus`, Motion+ springs, MotionScore audits, transition editor; sign in from the MCP settings).
- `/hyperui:doctor`: `Motion AI Kit skill` and `Motion MCP` rows.
- `motion` specialist: uses the kit's `/motion` skill or `motion` MCP when present for docs/examples, CSS springs and audits; hyperui's recipes stay the taste and choreography layer.

## 0.4.5 — 2026-10-03
- README Examples: three animated clips replace the static strip and the dashboard PNG — `docs/assets/examples/directions.webp` (Ledger · Monolith · Atelier loading with their entrance motion, CTA hover, scroll, caption chip with the type pairing; 9.7 s), `dashboard.webp` (the `viz` what–why–how card first, then KPIs and two live tooltips; 8 s), `ship.webp` (the question typed, the unedited answer line by line; 8 s). Stills and HTML sources stay under a "Stills and sources" fold.
- New sources: `docs/assets/examples/directions/` (the three direction pages from the test run, interactive), `examples/ship-terminal.html` (time-driven terminal page, `?record` + `window.__seek(t)`), `examples/record/` (Playwright recorders + `encode.sh`); how-to in `docs/assets/README.md`. Docs-only release.

## 0.4.4 — 2026-10-03
- README: animated hero demo (`docs/assets/demo.webp`, 9 s) recorded from a real page built in the hyperui style (`docs/assets/demo/`, interactive when opened).
- `scripts/check.sh`: company-agnostic grep skips binary files (`-I`).

## 0.4.3 — 2026-10-03
- Repository moved to the `tizonai` GitHub organization: `claude plugin marketplace add tizonai/hyperui` (the old `tizon9804/hyperui` keeps working through GitHub redirects).

## 0.4.2 — 2026-10-03
- npm package renamed to `@tizonai/hyperui` (scoped under the tizonai org); the binary stays `hyperui`: `npx @tizonai/hyperui install`.

## 0.4.1 — 2026-10-03
- License changed from MIT to Apache License 2.0; `NOTICE` added (attribution must be preserved).

## 0.4.0 — 2026-10-03
- **Work on a repo from any directory:** `/hyperui --repo <path> …` (or the path said in words) makes that path the project root for everything — `.hyperui/`, repo inspection, specs, code, ship/infra files — and remembers it per directory in the per-machine `~/.claude/plugins/data/hyperui/user.md` (`roots:`; pinned there because hooks and Bash-tool commands see different `CLAUDE_PLUGIN_DATA`), so it is said once; `--repo .` forgets it. Onboarding asks "Where is the repo?" only when the current directory does not look like a project.
- **Several repos from one directory:** `--repo` is repeatable (first = primary); each repo keeps its own `.hyperui/`, the primary holds `.hyperui/workspace.md` (repos, roles, cross-repo next step); routing by role word, one question when ambiguous; rules in `references/workspace.md`.
- `scripts/profile.sh`: `root`, `roots`, `root-set [--replace|--move] <path>...` (`--move` carries a `.hyperui/` started in cwd into the repo), `root-clear`, `inspect` (files, markers, manifest deps of a root outside cwd), `--repo` on every command, `HYPERUI_ROOT`; python core + awk fallback.
- Hooks: `welcome.sh` checks `<root>/.hyperui` and says which repo the directory works on; `permit.sh` also pre-approves Read/Edit/Write under `<root>/.hyperui/` for every resolved root (nothing else widened).
- Specialists: standardized root-resolution preamble + `profile.sh` allow on all 11; `check.sh` lints the exact sentence and the allow.
- `/hyperui:setup` preflight: Node 24 LTS recommended, ≥ 20 required (warns below 22); prints the install line for missing node/python3 per OS (brew `node@24`, `nvm install 24`, NodeSource 24.x) and offers to run it (`--install-prereqs`, Homebrew on macOS); `infra` offers to install Terraform once on first use. README: complete requirements (you need / installed for you).

## 0.3.0 — 2026-10-03
- One visible entry point `/hyperui`: short onboarding (≤ 3 questions, once per project), archetype detection (non-tech / dev / senior), routing, done/next every turn.
- Per-project memory in `.hyperui/` (profile, brief, design, spec, decisions, state, ship) + per-machine profile; `--private` gitignores it.
- Specialists (hidden, routed automatically): design (artifacts before build, Impeccable gate), motion, video, spec (gated SDD or SDD-lite), build (rules for Go, Python, TypeScript/JS, React/Next.js, Angular, Swift, Flutter/Dart, Rust, Java; TDD), review (OWASP Top 10:2025, ASVS 5.0, complexity, safety), patterns, ship (providers by budget × level × seller country; never buys or deploys), infra (Terraform/Terragrunt, Fargate vs EKS, OIDC CI), viz (Munzner what–why–how), git (Conventional Commits, SemVer, no amend/force-push).
- Hooks: SessionStart welcome/routing context; PreToolUse pre-approval limited to the plugin's own skills, reference reads and `profile.sh`.
- `scripts/check.sh` strict gate (validate, lint, company-agnostic grep); 5 `claude plugin eval` cases; `docs/architecture.md`; `docs/research/`.

## 0.2.0 — 2026-10-03
- `setup` installs Impeccable (pbakaus/impeccable) as well.

## 0.1.0 — 2026-10-03
- First release: `setup`/`doctor` installing HyperFrames skills, Motion, UI UX Pro Max, Anthropic frontend-design, 21st.dev MCP; skills design, motion, video.
