#!/usr/bin/env bash
# Scaffold: copy this case's fixture/ tree into the empty eval workspace (cwd), install its
# node_modules so `vitest` works inside the agent sandbox (no network there), and make it a git
# repo with one commit so "deja listo el commit" has a history to build on.
# Runs outside the agent sandbox, only with `claude plugin eval --scaffold`.
set -euo pipefail
CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$CASE_DIR/fixture"
[ -d "$SRC" ] || { echo "fixture dir missing: $SRC" >&2; exit 1; }
# cp -R of "$SRC/." copies dotfiles (.hyperui/, .gitkeep) too.
cp -R "$SRC/." "$PWD/"
rm -f "$PWD/.gitkeep"
# The scaffold environment can carry NODE_ENV=production, which makes npm omit devDependencies
# (vitest, Testing Library) — force them in. Inside the sandbox npm itself is not runnable, so the
# agent runs the installed binaries directly (node_modules/.bin/vitest run) and edits package.json
# by hand when `npm version` is unavailable (versioning.md §2).
if command -v npm >/dev/null 2>&1; then
  env -u NODE_ENV npm install --include=dev --no-audit --no-fund --loglevel=error >&2 || echo "fixture: npm install failed; the agent must say tests could not run" >&2
  [ -x node_modules/.bin/vitest ] || echo "fixture: vitest missing after install; the agent must say tests could not run" >&2
else
  echo "fixture: npm not found; the agent must say tests could not run" >&2
fi
# A real repo with history (identity set per command; nothing global is touched).
if command -v git >/dev/null 2>&1; then
  printf 'node_modules/\ndist/\n.DS_Store\n' > .gitignore
  git init -q -b main
  git -c user.name="Acme Studio" -c user.email="dev@acme.example" add -A
  git -c user.name="Acme Studio" -c user.email="dev@acme.example" commit -q -m "chore(release): v0.3.1" || echo "fixture: initial commit failed" >&2
else
  echo "fixture: git not found; the agent must say so and offer git init" >&2
fi
ls -la "$PWD" >&2
