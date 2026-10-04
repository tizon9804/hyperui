# Versioning: every change hyperui makes moves the version

Sources: https://semver.org/ · https://keepachangelog.com/en/1.1.0/ · https://www.conventionalcommits.org/en/v1.0.0/

The user must be able to tell, from the running product and from the repo, whether a given change is
in a given build. So every code change hyperui makes bumps the version and adds a changelog line, in
the **same commit** as the change. `release.md` is for cutting a tagged release out of several commits;
this file is the per-change rule that feeds it. (From real use: a site was changed and stayed at 0.3.1,
so nobody could tell whether the deployed build had the change.)

## 1. Policy (SemVer 2.0.0)

| Change | Bump | Decided by |
|---|---|---|
| Any code change the user can run: fix, perf, refactor, style, chore that touches code, copy or docs rendered inside the app | **PATCH** | default |
| A user-facing feature: new screen, option, command, endpoint | **MINOR** | task/spec type `feature`, or commit type `feat` |
| Breaking change (`!` / `BREAKING CHANGE:`) | **MAJOR** — only after the user confirms it in words; while `0.y.z`, MINOR | the user |
| Docs outside the app (`README`, `docs/`), tests only, CI only | no bump, no changelog line (the commit still happens) | default |

Classification comes from the task or spec type when there is one, else from the Conventional Commit type you are
about to propose: `feat` → MINOR · `fix` `perf` `refactor` `style` `chore` → PATCH when code changed · `docs` `test` `ci`
→ none. Doubt → PATCH. The commit type and the bump must agree: a copy, text or visual tweak with no new capability is
`fix`/`style` + PATCH, never `feat` + PATCH. Several commits in one turn → one bump for the turn, the highest that applies.
Already bumped in this working tree (the version file differs from `HEAD`) → keep it; never bump twice for one change.

## 2. Version source per stack

| Stack | Where the version lives | How to bump |
|---|---|---|
| Node / TS (npm) | `package.json` `"version"` + `package-lock.json` (top-level `version` twice) | `npm version --no-git-tag-version x.y.z` (both files); `npm` unavailable → edit both by hand |
| pnpm / yarn | same files (`pnpm-lock.yaml` / `yarn.lock` carry no root version) | `pnpm version x.y.z --no-git-tag-version` · `yarn version --new-version x.y.z --no-git-tag-version` |
| Python | `pyproject.toml` `[project] version` (or `[tool.poetry] version`; `dynamic` → the file it points to) | edit the line |
| Rust | `Cargo.toml` `[package] version` + `Cargo.lock` | edit, then `cargo update -p <crate>` (or any `cargo build`) |
| Dart / Flutter | `pubspec.yaml` `version: x.y.z+build` | bump `x.y.z`, increment `+build` |
| Swift / Xcode | `project.yml` (XcodeGen) or `Info.plist` / build settings `CFBundleShortVersionString`; `CFBundleVersion` increments on every bump | `agvtool new-marketing-version x.y.z` + `agvtool next-version -all`, or edit both |
| Java | Gradle `version = "x.y.z"` in `build.gradle(.kts)` · Maven `<version>` in `pom.xml` | edit · `mvn versions:set -DnewVersion=x.y.z` |
| Android | `versionName "x.y.z"` + `versionCode` (integer, always +1) in `app/build.gradle(.kts)` | edit both |
| Go | no file: the git tag `vX.Y.Z` is the version; `var Version` set with `-ldflags "-X main.Version=…"` when the app shows it | tag only |

Detect once per project and store the path with `profile.sh set version_file <path>`; next time read `profile.sh get version_file`.
Several candidates → the one the build reads; ask only if still ambiguous.
**Monorepo:** bump the package that changed (its own manifest); the root manifest only when it has a `version` and the
project releases as one unit. Tag convention then `<package>-vX.Y.Z` if the repo already uses it.
**Release tooling present** (release-please, semantic-release, Changesets) → follow it and say so in one line: Changesets →
`npx changeset` entry instead of a bump; the other two bump in CI from commit types, so the right commit type is the bump.

## 3. Changelog (Keep a Changelog 1.1.0)

- `CHANGELOG.md` at the repo root (package root in a monorepo). Missing → create it with the header in `release.md` §4.
- One block per version, newest first, with today's ISO date: `## [x.y.z] - YYYY-MM-DD`. A project that already uses another
  heading style (`## x.y.z — YYYY-MM-DD`) keeps it. Items under `## [Unreleased]`, if present, move into the new block.
- Sections Added / Changed / Fixed / Removed / Security as needed; one bullet per change, written for the people who use the
  product, not a commit subject: "The main button now reads 'Empezar'", not "update App.jsx".
- User-facing bullets in the product's language(s) (`product_languages`); internal bullets in English.

## 4. In the commit

The version file(s) and `CHANGELOG.md` are staged **with the change**, never in a separate "bump" commit after it:
- Change + bump together (the normal case) → the change's own message (`feat(hero): …`, `fix(login): …`) with the body
  line `Bumps to vX.Y.Z.`
- Pure release commit (only the bump + changelog, closing several commits) → `chore(release): vX.Y.Z` (`release.md` §5).
- Tag `vX.Y.Z` (or the project's existing convention) after the merge/push, with its own explicit yes — `release.md` §5.
  Never move or delete a pushed tag.

## 5. Opt-out and memory

- "No versioning for this project" (any wording) → `profile.sh set versioning off`; from then on skip §1–§4 and stay silent
  about it. The template default is `versioning: auto`.
- The first bump in a project appends one line to `.hyperui/decisions.md`:
  `YYYY-MM-DD · versioning = SemVer; PATCH per change, MINOR per feature; version in <file> · tells which build has which change · https://semver.org/`
- A UI project also shows the version and exposes it to machines (`/version.json`, `<meta name="app-version">`):
  `${CLAUDE_PLUGIN_ROOT}/skills/design/references/version-stamp.md`. After a deploy, `ship` verifies the live version.
