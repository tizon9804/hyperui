# Release: bump + changelog + tag

Sources: https://semver.org/ · https://keepachangelog.com/en/1.1.0/ ·
https://www.conventionalcommits.org/en/v1.0.0/

Every step that changes the repo or the remote waits for its own explicit yes: the version, the
changelog block, the release commit, the merge(s), the tag, the push.

## 1. Preconditions

- Clean working tree (`git status --short` empty). Not clean → stop.
- On the release source branch: the default branch (GitHub Flow / trunk-based) or `develop`
  (Git Flow). Up to date: `git pull --ff-only origin <branch>`.
- Release tooling already in the repo? `release-please-config.json` /
  `.release-please-manifest.json` → release-please opens the release PR; `.releaserc*` or
  `release` key in `package.json` → semantic-release runs in CI; `.changeset/` → run
  `npx changeset version`. Then follow that tool and skip the manual steps below.

## 2. Find the version

| Stack | File and field |
|---|---|
| Node / TS | `package.json` → `"version"` (also `package-lock.json` via `npm version --no-git-tag-version`) |
| Python | `pyproject.toml` → `[project] version` (or `[tool.poetry] version`) |
| Rust | `Cargo.toml` → `[package] version` |
| Flutter / Dart | `pubspec.yaml` → `version: x.y.z+build` |
| Apple | `MARKETING_VERSION` in the Xcode project (`agvtool` or build settings) |
| Other / none | ask which file holds it; if none, the tag alone is the version |

Several candidates → ask which one is the source of truth. Last tag:
`git describe --tags --abbrev=0` (none → first release; propose `0.1.0` for a new project, or
`1.0.0` if it is already used in production).

## 3. Propose the bump (SemVer 2.0.0)

From `git log <last-tag>..HEAD --oneline`:

- Any `!` or `BREAKING CHANGE:` → **MAJOR** (while `0.y.z`: MINOR).
- Else any `feat` → **MINOR**.
- Else → **PATCH**.

Show `current → proposed` with the one commit that decided it. The user can override.
Pre-releases: `1.4.0-rc.1`; build metadata (`+build`) never decides precedence.

## 4. Changelog (Keep a Changelog 1.1.0)

`CHANGELOG.md` missing → offer to create it with this header:

```markdown
# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.1.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [Unreleased]
```

New block, inserted after `## [Unreleased]` (whose items move into it) and before the first
existing `## [` version:

```markdown
## [1.5.0] - 2026-10-03

### Added
- Coupon code field at checkout.

### Fixed
- Sign-in now returns to the page the user came from.
```

Mapping: `feat` → Added · `fix` → Fixed · behavior changes and `perf` → Changed · deprecations
→ Deprecated · removals → Removed · vulnerability fixes → Security. Skip `docs`/`test`/`ci`/
`chore` unless users would care. Write entries for humans (what changed for them), not commit
subjects. ISO date `YYYY-MM-DD`. Keep the project's existing headings if it already uses others.
Optional compare links at the bottom: `[1.5.0]: https://github.com/<o>/<r>/compare/v1.4.3...v1.5.0`.

## 5. Commit, tag, push

### GitHub Flow / trunk-based

```bash
git add <version-file> CHANGELOG.md
git commit -m "chore(release): v1.5.0"
git tag -a v1.5.0 -m "v1.5.0"
git push origin <default>
git push origin v1.5.0
git ls-remote origin refs/heads/<default>   # = git rev-parse HEAD
git ls-remote --tags origin v1.5.0          # tag present
```

Protected default branch → put the release commit on `release/v1.5.0`, open a PR, tag the
merge commit after it lands.

### Git Flow

```bash
git checkout -b release/1.5.0 develop
# bump version file + CHANGELOG, then:
git commit -m "chore(release): v1.5.0"
git checkout main    && git merge --no-ff release/1.5.0 -m "Merge release/1.5.0 into main"
git tag -a v1.5.0 -m "v1.5.0"
git checkout develop && git merge --no-ff release/1.5.0 -m "Merge release/1.5.0 into develop"
git branch -d release/1.5.0
git push origin main develop v1.5.0          # then ls-remote each
```

`git flow` CLI installed and initialized (`git flow version`)? `git flow release start 1.5.0` /
`git flow release finish -n 1.5.0` + manual annotated tag is equivalent. Not installed → the
plain commands above; do not stop the release for it.

## 6. After

- Optional GitHub release: `gh release create v1.5.0 --title v1.5.0 --notes-file <block.md>`.
- Append to `.hyperui/decisions.md`:
  `2026-10-03 · release v1.5.0 · MINOR: feat(checkout) coupon field · https://semver.org/`
- Report: version, file bumped, tag, merges, pushes verified.
- Never delete or move a pushed tag. A bad release is fixed by a new PATCH release.
