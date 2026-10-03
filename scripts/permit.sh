#!/usr/bin/env bash
# PreToolUse hook (hooks/hooks.json): pre-approve the plugin's OWN surface, nothing else.
#
# Why it exists: a skill that declares `allowed-tools` is itself gated by the Skill tool in the
# default permission mode (interactive: a prompt; headless -p: denied). Every hyperui specialist
# declares `allowed-tools` so it can read its references under ${CLAUDE_PLUGIN_ROOT}, so without
# this hook the single-door routing (hyperui -> specialist) prompts on every hop.
#
# Allows, by returning permissionDecision "allow":
#   - Skill            whose name starts with "hyperui:"
#   - Read/Glob/Grep   of a path under the plugin root (references, templates)
#   - Bash             commands that start with "<plugin root>/scripts/profile.sh" (quoted or not)
# Anything else: no output, exit 0 -> the normal permission flow decides. Deny/ask rules in the
# user's settings still override an "allow" from here (documented hook semantics).
set -u
ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
INPUT="$(cat)"
command -v python3 >/dev/null 2>&1 || exit 0
HOOK_INPUT="$INPUT" HOOK_ROOT="$ROOT" python3 - <<'PY'
import json, os, sys
root = os.path.realpath(os.environ["HOOK_ROOT"])
try:
    d = json.loads(os.environ["HOOK_INPUT"])
except Exception:
    sys.exit(0)
tool = d.get("tool_name"); inp = d.get("tool_input") or {}
ok = False
if tool == "Skill" and str(inp.get("skill", "")).startswith("hyperui:"):
    ok = True
elif tool in ("Read", "Glob", "Grep"):
    p = inp.get("file_path") or inp.get("path") or ""
    ok = bool(p) and os.path.realpath(p).startswith(root + os.sep)
elif tool == "Bash":
    cmd = str(inp.get("command", "")).lstrip()
    script = root + "/scripts/profile.sh"
    ok = cmd.startswith(script + " ") or cmd.startswith('"' + script + '" ') or cmd == script or cmd == '"' + script + '"'
if ok:
    print(json.dumps({"hookSpecificOutput": {"hookEventName": "PreToolUse",
          "permissionDecision": "allow", "permissionDecisionReason": "hyperui: plugin's own skill/reference/profile.sh"}}))
PY
exit 0
