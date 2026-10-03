#!/usr/bin/env bash
# SessionStart (startup) hook: introduce hyperui once per project.
# Resolves the project root(s) with profile.sh (cwd, or the repo(s) remembered for this
# directory via `/hyperui --repo <path>`), then prints the full intro as SessionStart
# additionalContext when <root>/.hyperui/ is missing; when it exists, prints one routing line so
# bare requests ("what can you do?", "where do I start?", product work) still reach the hyperui
# skill instead of generic Claude Code help. When this directory works on another repo, says so.
set -u

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
ROOTS="$("$PLUGIN_ROOT/scripts/profile.sh" roots 2>/dev/null || true)"
[ -n "$ROOTS" ] || ROOTS="$PROJECT_DIR"
PRIMARY="$(printf '%s\n' "$ROOTS" | head -n1)"

# JSON string escaping for paths (backslash, double quote); paths are one line each.
esc() { printf '%s' "$1" | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g'; }
LIST="$(printf '%s\n' "$ROOTS" | paste -sd, - | sed 's/,/, /g')"
WORKS_ON=""
if [ "$PRIMARY" != "$PROJECT_DIR" ] || [ "$(printf '%s\n' "$ROOTS" | grep -c .)" -gt 1 ]; then
  WORKS_ON=" This directory works on $(esc "$LIST") (remembered root(s); run profile.sh root / roots for the exact paths, keep .hyperui/ and every repo read or write there, and say /hyperui --repo . to work here instead)."
fi

if [ -d "$PRIMARY/.hyperui" ]; then
  printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This project uses hyperui (.hyperui/ present in %s). For anything about designing, planning, building, reviewing or shipping the product, and for questions like what can you do or where do I start, invoke the hyperui skill first; it reads .hyperui/profile.md and .hyperui/state.md and routes.%s"}}\n' "$(esc "$PRIMARY")" "$WORKS_ON"
  exit 0
fi

# Plain ASCII text, no quotes/backslashes, so the JSON below needs no escaping beyond \n.
printf '{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"hyperui welcome (this project has no .hyperui/ folder yet).\\nIntro master text (English; render it in the user'"'"'s language):\\nI'"'"'m hyperui. I help you take a product with a UI from idea to shipped: I show you how it\\nwould look first, then plan it, build it, check it, and guide you to put it online. I'"'"'ll ask\\nyou at most three things now and remember the rest in a .hyperui/ folder in this project,\\nso you never answer twice. You can just tell me what you want in your own words.\\nIf the user has not yet been introduced to hyperui in this project, greet them in THEIR language with this intro, then follow the hyperui skill.%s"}}\n' "$WORKS_ON"
exit 0
