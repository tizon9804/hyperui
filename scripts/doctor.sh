#!/usr/bin/env bash
# hyperui:doctor — read-only report of the hyperui stack in this project / machine.
set -uo pipefail

PROJECT_SKILLS="$PWD/.claude/skills"
GLOBAL_SKILLS="$HOME/.claude/skills"

row() { printf '  %-24s %-14s %s\n' "$1" "$2" "$3"; }

echo "[hyperui] doctor — cwd: $PWD"
echo
row "component" "status" "where / detail"
row "------------------------" "--------------" "--------------"

# Motion
if [[ -f package.json ]] && grep -Eq '"motion"[[:space:]]*:' package.json; then
  V="$(node -e 'try{console.log(require("./node_modules/motion/package.json").version)}catch(e){process.exit(1)}' 2>/dev/null || true)"
  if [[ -n "$V" ]]; then row "Motion" "installed" "motion@$V"; else row "Motion" "declared" "in package.json, not in node_modules (run install)"; fi
elif [[ -f package.json ]]; then
  row "Motion" "missing" "package.json without motion"
else
  row "Motion" "n/a" "no package.json in cwd"
fi

# Motion AI Kit (official /motion skill)
if   [[ -f "$PROJECT_SKILLS/motion/SKILL.md" ]]; then row "Motion AI Kit skill" "installed" "project .claude/skills/motion"
elif [[ -f "$GLOBAL_SKILLS/motion/SKILL.md" ]];  then row "Motion AI Kit skill" "installed" "global ~/.claude/skills/motion"
else row "Motion AI Kit skill" "missing" "run /hyperui:setup (motion-ai package)"; fi

# HyperFrames skills
hf_report() {
  local dir="$1" label="$2"
  if [[ -d "$dir" ]]; then
    local n; n="$(find "$dir" -maxdepth 2 -name SKILL.md 2>/dev/null | wc -l | tr -d ' ')"
    local hf; hf="$(find "$dir" -maxdepth 1 -type d -name 'hyperframes*' 2>/dev/null | wc -l | tr -d ' ')"
    if [[ "$hf" -gt 0 ]]; then row "HyperFrames skills" "installed" "$label: $hf hyperframes-* dirs, $n SKILL.md total in dir"; return 0; fi
  fi
  return 1
}
hf_report "$PROJECT_SKILLS" "project" || hf_report "$GLOBAL_SKILLS" "global" || row "HyperFrames skills" "missing" "run /hyperui:setup"

# UI UX Pro Max
if   [[ -d "$PROJECT_SKILLS/ui-ux-pro-max" ]]; then row "UI UX Pro Max" "installed" "project .claude/skills/ui-ux-pro-max"
elif [[ -d "$GLOBAL_SKILLS/ui-ux-pro-max" ]];  then row "UI UX Pro Max" "installed" "global ~/.claude/skills/ui-ux-pro-max"
else row "UI UX Pro Max" "missing" "run /hyperui:setup"; fi

# claude-dependent checks
if command -v claude >/dev/null 2>&1; then
  if claude plugin list 2>/dev/null | grep -q 'frontend-design'; then
    row "frontend-design plugin" "installed" "claude plugins (claude-plugins-official)"
  else
    row "frontend-design plugin" "missing" "claude plugin install frontend-design@claude-plugins-official"
  fi
  if claude plugin list 2>/dev/null | grep -q 'impeccable'; then
    row "Impeccable plugin" "installed" "claude plugins (impeccable)"
  else
    row "Impeccable plugin" "missing" "run /hyperui:setup (pbakaus/impeccable)"
  fi
  MCP_LIST="$(claude mcp list 2>/dev/null || true)"
  if grep -Eq '^motion:' <<<"$MCP_LIST"; then
    MP=""; grep -Eq '^motion-plus:' <<<"$MCP_LIST" && MP=" + motion-plus"
    row "Motion MCP" "installed" "claude mcp: motion$MP (https://mcp.motion.dev)"
  else
    row "Motion MCP" "missing" "run /hyperui:setup (or claude mcp add --transport http motion https://mcp.motion.dev)"
  fi
  if grep -Eq '^21st[: ]' <<<"$MCP_LIST"; then
    row "21st.dev MCP" "installed" "claude mcp (user scope)"
  else
    row "21st.dev MCP" "missing" "key at https://21st.dev/mcp → /hyperui:setup --21st-key <key>"
  fi
else
  row "frontend-design plugin" "unknown" "claude CLI not found"
  row "Impeccable plugin" "unknown" "claude CLI not found"
  row "Motion MCP" "unknown" "claude CLI not found"
  row "21st.dev MCP" "unknown" "claude CLI not found"
fi

# tools
command -v node    >/dev/null 2>&1 && row "node"    "ok" "$(node --version)"    || row "node"    "missing" "https://nodejs.org"
command -v python3 >/dev/null 2>&1 && row "python3" "ok" "$(python3 --version 2>&1 | awk '{print $2}')" || row "python3" "missing" "needed by UI UX Pro Max scripts"
