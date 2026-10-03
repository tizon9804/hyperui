# Changelog

All notable changes to hyperui. Format: Keep a Changelog; versions follow SemVer.

## 0.4.0 — 2026-10-03
- **Work on a repo from any directory:** `/hyperui --repo <path> …` (or the path said in words) makes that path the project root for everything — `.hyperui/`, repo inspection, specs, code, ship/infra files — and remembers it per directory in the per-machine `~/.claude/plugins/data/hyperui/user.md` (`roots:`; pinned there because hooks and Bash-tool commands see different `CLAUDE_PLUGIN_DATA`), so it is said once; `--repo .` forgets it. Onboarding asks "Where is the repo?" only when the current directory does not look like a project.
- **Several repos from one directory:** `--repo` is repeatable (first = primary); each repo keeps its own `.hyperui/`, the primary holds `.hyperui/workspace.md` (repos, roles, cross-repo next step); routing by role word, one question when ambiguous; rules in `references/workspace.md`.
- `scripts/profile.sh`: `root`, `roots`, `root-set [--replace] <path>...`, `root-clear`, `--repo` on every command, `HYPERUI_ROOT`; python core + awk fallback.
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
