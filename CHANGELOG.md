# Changelog

All notable changes to hyperui. Format: Keep a Changelog; versions follow SemVer.

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
