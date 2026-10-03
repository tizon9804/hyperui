# Hotfix: fix what is in production, fast and traceable

Sources: https://nvie.com/posts/a-successful-git-branching-model/ (hotfix branches) ·
https://trunkbaseddevelopment.com/ (fix forward / release branches) · https://semver.org/

Same gates as a release: the version, the changelog block, the commit, each merge, the tag and
the push each wait for an explicit yes.

## 1. Start

Preconditions: clean tree; know what is in production — the latest release tag
(`git describe --tags --abbrev=0`) or the default branch head if the project deploys from it.

| Model | Branch from | Branch name |
|---|---|---|
| GitHub Flow / trunk-based, deploys from `main` | `main` (up to date) | `hotfix/<short-words>` or `fix/<short-words>` |
| Releases from tags, `main` already moved on | the production tag: `git checkout -b hotfix/1.4.4 v1.4.3` | `hotfix/1.4.4` |
| Git Flow | `main` | `hotfix/1.4.4` (`git flow hotfix start 1.4.4` if the CLI is set up) |

Version = PATCH + 1 of the production version; show it and wait.

## 2. Fix

- Smallest change that fixes it, plus a test that fails without the fix.
- Commit with Conventional Commits: `fix(<scope>): <what now works>` — after the user approves
  the message, like any commit.
- No unrelated cleanups in a hotfix.

## 3. Finish

1. Bump the version file to `x.y.(z+1)`; add a changelog block with only `### Fixed`
   (ask for a one-line user-facing description if the commits do not make it obvious).
   Commit: `chore(release): v1.4.4`.
2. Land it:
   - **GitHub Flow / trunk-based**: open a PR to `main` (fast review), merge, tag the merge
     commit `v1.4.4`, push the tag.
   - **Tag-based (main moved on)**: tag `v1.4.4` on the hotfix branch, push branch + tag, then
     bring the fix to `main` with a PR (merge or `git cherry-pick -x <sha>` onto a new branch —
     a new commit, no history rewrite).
   - **Git Flow**:
     ```bash
     git checkout main    && git merge --no-ff hotfix/1.4.4 -m "Merge hotfix/1.4.4 into main"
     git tag -a v1.4.4 -m "v1.4.4"
     git checkout develop && git merge --no-ff hotfix/1.4.4 -m "Merge hotfix/1.4.4 into develop"
     git branch -d hotfix/1.4.4
     git push origin main develop v1.4.4
     ```
     A `release/*` branch is open → merge the hotfix into it instead of `develop`.
3. Verify every pushed ref with `git ls-remote` (sha / tag present) before reporting.
4. Deploying is not part of this skill: hand off to the `ship` specialist; never deploy to
   production without the user's explicit go.
5. Append to `.hyperui/decisions.md`:
   `YYYY-MM-DD · hotfix v1.4.4 · <one-line cause> · https://semver.org/`

## Never

- Force-push a shared branch to "clean up" the hotfix.
- Move or delete an existing tag; a bad hotfix gets a new PATCH.
- Skip hooks or CI to go faster.
