---
name: git
description: "Commits, branches, pull requests, releases and hotfixes for the user's repo: Conventional Commits, SemVer, changelog, branching model by team size. Use when the user asks to commit, save or upload changes to git, open or describe a PR, cut a release, bump a version, tag, write the changelog, start or finish a hotfix, or pick a branching model — in any language (\"haz commit\", \"súbelo a git\", \"saca una versión\")."
user-invocable: false
allowed-tools:
  - Bash(${CLAUDE_PLUGIN_ROOT}/scripts/profile.sh *)
  - Read(//${CLAUDE_PLUGIN_ROOT}/**)
  - Edit(.hyperui/**)
---

# hyperui:git — commits, PRs, releases, hotfixes

Do git like a careful senior on the user's own repo: small reviewable changes, messages that
tools can read, versions that mean something, and nothing irreversible without a yes.

## 0. Before anything

1. Resolve the project root with `${CLAUDE_PLUGIN_ROOT}/scripts/profile.sh root` and use it (absolute paths) for `.hyperui/` and for every repo read/write. If `<root>/.hyperui/profile.md` is missing, invoke the `hyperui` skill first (it onboards and routes); otherwise read `profile.md` and `state.md` and never re-ask what they hold. With several roots (`profile.sh roots`), work in the repo the request or the touched file belongs to, with that repo's `.hyperui/` (rules: `${CLAUDE_PLUGIN_ROOT}/references/workspace.md`).
   Profile fields used: `archetype`, `conversation_language`, any ticketing tool in the notes;
   also `.hyperui/decisions.md` (a branching model already chosen is final; none → no decision yet).
2. Orient (read-only, safe without asking):
   ```bash
   git status --short
   git branch --show-current
   git log --oneline -10
   git remote -v
   ```
3. Not a git repo → say so in one line and offer `git init` (ask first).
4. Reply in the user's language; commit messages, PR text, changelog and tags stay **English**
   unless the profile says otherwise.

## 1. Hard rules (never relaxed, whatever the user's archetype)

- **Commit only after the user approves the exact message.** Show it, stop, wait. "haz commit"
  is a request to propose, not approval of a message they have not seen.
- **Never `git commit --amend`** — not even on an unpushed commit. A correction is a new commit.
- **Never force-push** (`--force`, `--force-with-lease`), never rewrite published history
  (`rebase` of pushed commits, `filter-branch`, `reset --hard` that drops work) unless the user
  explicitly asks for that exact operation after you name the risk in one line.
- **Never `--no-verify`**; never skip hooks. A failing hook is a finding: fix the cause.
- **UI changes are shown before they are committed, merged or pushed.** Before proposing any of those on a change
  that touches UI, check `<root>/.hyperui/design.md` has a `## Browser evidence` entry for it and that this reply or
  the previous one gave the user the local URL, the 360/768/1280 screenshots and "what to look at" (root §7). Missing →
  show it first (`${CLAUDE_PLUGIN_ROOT}/skills/design/references/browser-verify.md`), ask afterwards.
- **Never commit secrets**: scan the staged diff for `.env`, keys, tokens, certificates,
  credentials. Found one → unstage it, add it to `.gitignore`, tell the user. If it was already
  pushed, say it must be rotated — deleting it in a new commit is not enough.
- **Every push is verified** before saying "pushed":
  ```bash
  git rev-parse HEAD
  git ls-remote origin refs/heads/<branch>     # sha must equal HEAD
  ```
  Never pipe push output through `head`/`tail` (it hides failures). Mismatch → report it.
- Push, merge to the default branch, tag and release each need their own explicit yes.
- Do not commit directly to the default branch when the chosen model uses feature branches.

## 2. Branch before the first edit

In every repo that will change:

```bash
git fetch origin
git rev-list --left-right --count <default>...origin/<default>   # behind?
git checkout <default> && git pull --ff-only origin <default>
git checkout -b <type>/<two-or-three-words>                     # feat/checkout-page, fix/login-redirect
```

`<default>` = `git symbolic-ref --short refs/remotes/origin/HEAD` minus `origin/` (else `main`).
Stray uncommitted changes that are not part of this work → isolate them with an explicit
pathspec, never a blanket stash:

```bash
git stash push -u -m "<reason>" -- <only those paths>
```

Branching model per project: see `references/branching.md`. Decide it once, write it to
`.hyperui/decisions.md`, then stop asking.

## 3. Commit ("haz commit", "guarda los cambios", "commit this")

1. Look at the change: `git status --short`, `git diff`, `git diff --staged`,
   `git log --oneline -5` (match the repo's existing style when it already uses one).
2. Propose what to stage. Default: the files of this change by path. Use `git add -A` only
   when every changed/untracked file belongs to it; never stage `.env`, build output,
   `.DS_Store`, editor folders.
3. Draft a **Conventional Commits** message (`references/conventional-commits.md`):
   - `type(scope)!: description` — imperative, lowercase start, no period, first line ≤ 72.
   - Types: `feat`, `fix`, `docs`, `style`, `refactor`, `perf`, `test`, `build`, `ci`,
     `chore`, `revert`. Breaking change → `!` and a `BREAKING CHANGE:` footer.
   - Body (optional, wrapped at 72): why, not how. No ticket prefix in the subject; a
     `Refs: <id>` footer only if the user uses a tracker and gives the id.
   - Change mixes unrelated things → propose splitting into two commits.
4. **Show and stop.** Present the files to stage and the message in a fenced block, then one
   question: "Commit with this message?" Do not run `git add` or `git commit` in this turn.
5. On approval: stage exactly the approved files and commit with exactly the approved text
   (`git commit -F <tmpfile>` for multi-line). On edits: redraft and show again.
6. After committing: `git log --oneline -1`. Do not push unless asked; offer it in one line.
7. A hook (lint, commitlint, tests) rejects the commit → fix the cause, show the new
   message/diff if it changed, and make a **new** commit attempt — never `--no-verify`.

## 4. Pull request ("abre un PR", "open a PR")

1. Preconditions: on a feature branch, clean tree (else stop: commit or stash first), branch is
   up to date with the base (`git fetch && git log HEAD..origin/<base> --oneline`; behind →
   propose `git merge origin/<base>`, not a rebase of pushed work).
2. Base = default branch (Git Flow: `develop`); confirm only if ambiguous.
3. Draft from `git log <base>..HEAD` and `git diff <base>...HEAD`:
   - **Title**: Conventional Commit style (`feat(cart): add coupon field`), ≤ 72 chars.
   - **Body**: `references/pr-template.md` — what and why, how it was tested, screenshots
     when UI changed, checklist. If the repo already has `.github/pull_request_template.md`
     (or `docs/` / root), use the repo's template instead.
   - Large or mixed change → propose a split first (one concern per PR, schema/migrations
     before the code that needs them, each PR green on its own).
4. Show title + body; wait for approval. Then push (`git push -u origin <branch>`, verified
   per §1) and create: `gh pr create --base <base> --title … --body-file …` when `gh` is
   authenticated; otherwise give the compare URL and the ready-to-paste text.
5. Return the PR URL. Review fixes go in new commits on the same branch, never force-pushed.

## 5. Release ("saca una versión", "release", "bump version")

Full procedure: `references/release.md`. Summary:

1. Precondition: clean tree on the release source branch (default branch, or `develop` under
   Git Flow). Find the version file (`package.json`, `pyproject.toml`, `Cargo.toml`,
   `pubspec.yaml`, `*.xcodeproj` marketing version, …; none → ask) and the last tag
   (`git describe --tags --abbrev=0`).
2. Propose the **SemVer** bump from commits since the last tag: any breaking → MAJOR (MINOR
   while `0.y.z`), any `feat` → MINOR, otherwise PATCH. Show current → proposed; wait.
3. Draft the **Keep a Changelog** block (`## [x.y.z] - YYYY-MM-DD`, sections Added / Changed /
   Deprecated / Removed / Fixed / Security; move `## [Unreleased]` items in). Show; wait.
4. Commit `chore(release): vX.Y.Z` (version file + `CHANGELOG.md`) after approval, then the
   annotated tag `git tag -a vX.Y.Z -m "vX.Y.Z"` after approval, then push branch and that tag
   (`git push origin vX.Y.Z`, verified with `git ls-remote --tags origin vX.Y.Z`).
5. Optional: `gh release create vX.Y.Z --notes-file <block>` — ask.
6. Write the decision to `.hyperui/decisions.md`, one line:
   `YYYY-MM-DD · release vX.Y.Z · <why this bump> · https://semver.org/`.
7. Repo already uses release-please, semantic-release or Changesets → follow that tool instead
   of a manual bump; do not mix both.

## 6. Hotfix ("arréglalo en producción", "hotfix")

Full procedure: `references/hotfix.md`. Start from what is in production (the last release
tag or the default branch), branch `hotfix/x.y.(z+1)`, fix with a test, PATCH bump + `Fixed`
changelog entry, tag, and bring the fix back to every long-lived branch (`develop` under Git
Flow). Same approval gates as a release; never cherry-pick by rewriting history.

## 7. Tone per archetype

- **non-tech**: do the git part for them, explained in one plain line per step ("I'll save
  this change with a short note describing it — okay?"). One question per turn, with the
  recommended answer. Never mention rebase, reflog or detached HEAD unless they must act.
- **dev**: the command and one line of why.
- **senior**: the proposed message/command only; options only when asked.

## 8. Report

End each action with: what ran (commit sha / PR URL / tag), what was verified (`ls-remote`
match), and the next step in one line. Update `.hyperui/state.md` `next:` if it exists.

## Sources

Cite only URLs that are listed in a skill/reference or that you opened this session; never construct or guess a URL.

Open the source before stating a rule you are unsure of.

- Conventional Commits 1.0.0 — https://www.conventionalcommits.org/en/v1.0.0/
- Semantic Versioning 2.0.0 — https://semver.org/
- Keep a Changelog 1.1.0 — https://keepachangelog.com/en/1.1.0/
- A successful Git branching model (Git Flow, with the 2020 note) — https://nvie.com/posts/a-successful-git-branching-model/
- GitHub Flow — https://docs.github.com/en/get-started/using-github/github-flow
- Trunk-Based Development — https://trunkbaseddevelopment.com/
- GitHub pull request reviews — https://docs.github.com/en/pull-requests/reference/pull-request-reviews
- GitHub PR templates — https://docs.github.com/en/communities/using-templates-to-encourage-useful-issues-and-pull-requests/creating-a-pull-request-template-for-your-repository
- release-please — https://github.com/googleapis/release-please
- semantic-release — https://semantic-release.gitbook.io/semantic-release
- Changesets — https://github.com/changesets/changesets
