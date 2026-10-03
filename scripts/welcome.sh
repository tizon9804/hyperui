#!/usr/bin/env bash
# SessionStart (startup) hook: introduce hyperui once per project.
# Prints the full intro as SessionStart additionalContext when .hyperui/ is missing;
# when it exists, prints one routing line so bare requests ("what can you do?", "where do I
# start?", product work) still reach the hyperui skill instead of generic Claude Code help.
set -u

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
if [ -d "$PROJECT_DIR/.hyperui" ]; then
  cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"This project uses hyperui (.hyperui/ present). For anything about designing, planning, building, reviewing or shipping the product, and for questions like what can you do or where do I start, invoke the hyperui skill first; it reads .hyperui/profile.md and .hyperui/state.md and routes."}}
JSON
  exit 0
fi

# Plain ASCII text, no quotes/backslashes, so the JSON below needs no escaping beyond \n.
cat <<'JSON'
{"hookSpecificOutput":{"hookEventName":"SessionStart","additionalContext":"hyperui welcome (this project has no .hyperui/ folder yet).\nIntro master text (English; render it in the user's language):\nI'm hyperui. I help you take a product with a UI from idea to shipped: I show you how it\nwould look first, then plan it, build it, check it, and guide you to put it online. I'll ask\nyou at most three things now and remember the rest in a .hyperui/ folder in this project,\nso you never answer twice. You can just tell me what you want in your own words.\nIf the user has not yet been introduced to hyperui in this project, greet them in THEIR language with this intro, then follow the hyperui skill."}}
JSON
exit 0
