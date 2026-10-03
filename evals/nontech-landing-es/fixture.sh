#!/usr/bin/env bash
# Scaffold: copy this case's fixture/ tree into the empty eval workspace (cwd).
# Runs outside the agent sandbox, only with `claude plugin eval --scaffold`.
set -euo pipefail
CASE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SRC="$CASE_DIR/fixture"
[ -d "$SRC" ] || { echo "fixture dir missing: $SRC" >&2; exit 1; }
# cp -R of "$SRC/." copies dotfiles (.hyperui/, .gitkeep) too.
cp -R "$SRC/." "$PWD/"
rm -f "$PWD/.gitkeep"
ls -la "$PWD" >&2
