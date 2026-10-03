# Branching model by archetype and team

Decide once per project, write it to `.hyperui/decisions.md`, reuse it. If the repo already
shows a model (a `develop` branch, `release/*` branches, branch protection, CI on tags), follow
the repo and record that instead of proposing a change.

Decision line format:
`2026-10-03 · branching = GitHub Flow · solo, deploys continuously · https://docs.github.com/en/get-started/using-github/github-flow`

## Default by profile

| Who (profile `archetype` + team) | Model | Why |
|---|---|---|
| non-tech, any | **GitHub Flow**, hyperui runs it for them | one branch to understand (`main`) plus a short branch per change; no ceremony |
| dev, solo | **GitHub Flow** | `main` is always deployable; short `feat/…`/`fix/…` branches, squash-merge, delete |
| team, continuous deploy (web/SaaS) | **Trunk-based** (short-lived branches + PRs, feature flags) | integrates daily, avoids merge hell |
| team shipping explicit versions or supporting several versions (mobile apps, desktop, libraries, on-prem) | **Git Flow** (`main` + `develop` + `release/*` + `hotfix/*`) | stabilization branches and parallel version support |

Two-line trade-off to show a team that must choose:

- **Trunk-based / GitHub Flow**: fastest feedback and least merge pain, but needs good CI and
  feature flags to keep `main` releasable. Source: https://trunkbaseddevelopment.com/
- **Git Flow**: clear release stabilization and multi-version support, but more branches and
  merges; its author recommends GitHub Flow for continuously delivered software
  (2020 note). Source: https://nvie.com/posts/a-successful-git-branching-model/

Do not introduce Git Flow for a solo or non-tech user, even if asked casually — explain the
cost in one line and offer GitHub Flow; apply Git Flow if they insist.

## GitHub Flow (default)

Source: https://docs.github.com/en/get-started/using-github/github-flow

1. Branch from an up-to-date `main`: `git checkout main && git pull --ff-only && git checkout -b feat/<words>`.
2. Commit (Conventional Commits) and push the branch.
3. Open a PR (even solo: CI runs and the history explains itself).
4. Address review with new commits.
5. Merge (squash by default for solo; keep the PR title as the squash subject), then delete
   the branch: `git branch -d feat/<words>` and `git push origin --delete feat/<words>` (ask).
6. Releases: tag `main` (see `release.md`).

## Trunk-based

Source: https://trunkbaseddevelopment.com/

- Everyone integrates into `main` at least daily; branches live hours to a couple of days.
- Unfinished work hides behind feature flags (default off), not long branches.
- Release from `main` tags; cut a `release/x.y` branch only when a release needs hardening,
  fix on `main` first and cherry-pick (`-x`) into the release branch.

## Git Flow

Source: https://nvie.com/posts/a-successful-git-branching-model/

- `main`: only released code, every commit tagged. `develop`: integration branch.
- `feature/*` from `develop`, merged back with `--no-ff`.
- `release/x.y.z` from `develop`: version bump, changelog, fixes only; merged into `main`
  (tagged) and back into `develop`.
- `hotfix/x.y.z` from `main`: merged into `main` (tagged) and `develop` (see `hotfix.md`).
- The `git flow` CLI is optional; plain `git` commands do the same.

## Branch names

`<type>/<two-or-three-words>` in kebab-case, type from Conventional Commits:
`feat/coupon-field`, `fix/login-redirect`, `docs/setup-guide`, `chore/bump-deps`.
Git Flow keeps its prefixes (`feature/`, `release/`, `hotfix/`). A tracker id may be appended
only if the user's team requires it (`feat/coupon-field-123`).

## Merge strategy

- Squash: one commit per PR on `main`; best for solo and small teams.
- Merge commit (`--no-ff`): keeps branch history; used by Git Flow merges.
- Rebase-merge: linear history; only if the repo already uses it. Never rebase a branch others
  have pulled, and never force-push to "update" a PR — merge the base into the branch instead.
