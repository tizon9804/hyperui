#!/usr/bin/env bash
# hyperui:setup — install the frontend craft stack into the current project.
# Idempotent: every step checks before acting; failures never abort the others.
set -euo pipefail

GLOBAL=0
DRY=0
SKIP_HYPERFRAMES=0
SKIP_UIPRO=0
SKIP_MOTION=0
SKIP_21ST=0
SKIP_FD=0
SKIP_IMP=0
KEY_21ST="${TWENTY_FIRST_API_KEY:-}"

usage() {
  cat <<USAGE
Usage: setup.sh [options]

Installs into the current project (cwd):
  Motion (npm)            HyperFrames skills        UI UX Pro Max skill
  frontend-design plugin  Impeccable plugin        21st.dev MCP (user scope, needs a key)

Options:
  --global              Install the skills to ~/.claude/skills instead of ./.claude/skills
  --21st-key <key>      21st.dev API key (or export TWENTY_FIRST_API_KEY)
  --skip-hyperframes    --skip-uipro    --skip-motion    --skip-21st    --skip-frontend-design    --skip-impeccable
  --dry-run             Print every command instead of running it
  -h, --help            This help
USAGE
}

while [[ $# -gt 0 ]]; do
  case "$1" in
    --global) GLOBAL=1 ;;
    --dry-run) DRY=1 ;;
    --skip-hyperframes) SKIP_HYPERFRAMES=1 ;;
    --skip-uipro) SKIP_UIPRO=1 ;;
    --skip-motion) SKIP_MOTION=1 ;;
    --skip-21st) SKIP_21ST=1 ;;
    --skip-frontend-design) SKIP_FD=1 ;;
    --skip-impeccable) SKIP_IMP=1 ;;
    --21st-key) shift; KEY_21ST="${1:-}" ;;
    --21st-key=*) KEY_21ST="${1#*=}" ;;
    -h|--help) usage; exit 0 ;;
    *) echo "[hyperui] ✗ unknown option: $1"; usage; exit 2 ;;
  esac
  shift
done

ok()   { printf '[hyperui] ✓ %s\n' "$*"; }
skip() { printf '[hyperui] skip %s\n' "$*"; }
fail() { printf '[hyperui] ✗ %s\n' "$*"; }
warn() { printf '[hyperui] ! %s\n' "$*"; }
did()  { if [[ $DRY -eq 1 ]]; then printf "[hyperui] ✓ (dry-run) would: %s\n" "$*"; else printf "[hyperui] ✓ %s\n" "$*"; fi; }
status_installed() { if [[ $DRY -eq 1 ]]; then echo "would install"; else echo "installed"; fi; }

FAILURES=()
declare -a SUMMARY=()
record() { SUMMARY+=("$1|$2|$3"); }   # component | status | where

# run <description> <cmd...> — prints in dry-run, executes otherwise. Returns cmd status.
run() {
  local desc="$1"; shift
  if [[ $DRY -eq 1 ]]; then
    printf '[hyperui] dry-run %s:\n        %s\n' "$desc" "$*"
    return 0
  fi
  "$@"
}

if [[ $GLOBAL -eq 1 ]]; then
  SKILLS_DIR="$HOME/.claude/skills"
  SCOPE_LABEL="global (~/.claude/skills)"
else
  SKILLS_DIR="$PWD/.claude/skills"
  SCOPE_LABEL="project (./.claude/skills)"
fi

echo "[hyperui] setup — scope: $SCOPE_LABEL — cwd: $PWD"
[[ $DRY -eq 1 ]] && echo "[hyperui] DRY RUN: nothing will be installed"

# ---------------------------------------------------------------- a. preflight
PREFLIGHT_OK=1
if command -v node >/dev/null 2>&1; then
  NODE_MAJOR="$(node --version | sed -E 's/^v([0-9]+).*/\1/')"
  if [[ "$NODE_MAJOR" -ge 18 ]]; then
    ok "node $(node --version)"
  else
    fail "node >= 18 required (found $(node --version))"; PREFLIGHT_OK=0
  fi
else
  fail "node not found (https://nodejs.org)"; PREFLIGHT_OK=0
fi
if command -v npm >/dev/null 2>&1; then ok "npm $(npm --version)"; else fail "npm not found"; PREFLIGHT_OK=0; fi
if command -v python3 >/dev/null 2>&1; then
  ok "python3 $(python3 --version 2>&1 | awk '{print $2}') (UI UX Pro Max search scripts)"
else
  warn "python3 not found — UI UX Pro Max search/design-system scripts need it"
fi
if command -v claude >/dev/null 2>&1; then
  ok "claude CLI $(claude --version 2>/dev/null | head -1)"
  HAS_CLAUDE=1
else
  warn "claude CLI not found — frontend-design, Impeccable and 21st MCP steps will be skipped"
  HAS_CLAUDE=0
fi
if [[ $PREFLIGHT_OK -eq 0 ]]; then
  FAILURES+=("preflight")
  warn "preflight failed; npm-based steps will likely fail too"
fi

# ---------------------------------------------------------------- b. motion
if [[ $SKIP_MOTION -eq 1 ]]; then
  skip "motion (--skip-motion)"; record "Motion" "skipped" "-"
elif [[ ! -f package.json ]]; then
  skip "motion: no package.json in cwd (not a JS project)"; record "Motion" "skipped (no package.json)" "-"
elif grep -Eq '"motion"[[:space:]]*:' package.json; then
  ok "motion already in package.json"; record "Motion" "present" "package.json"
else
  if   [[ -f pnpm-lock.yaml ]]; then PM=pnpm; CMD=(pnpm add motion)
  elif [[ -f yarn.lock ]];      then PM=yarn; CMD=(yarn add motion)
  elif [[ -f bun.lockb || -f bun.lock ]]; then PM=bun; CMD=(bun add motion)
  else PM=npm; CMD=(npm install motion); fi
  if run "install motion via $PM" "${CMD[@]}"; then
    did "motion installed ($PM)"; record "Motion" "$(status_installed)" "package.json ($PM)"
  else
    fail "motion install failed ($PM)"; FAILURES+=("motion"); record "Motion" "FAILED" "-"
  fi
fi

# ---------------------------------------------------------------- c. hyperframes
if [[ $SKIP_HYPERFRAMES -eq 1 ]]; then
  skip "hyperframes (--skip-hyperframes)"; record "HyperFrames skills" "skipped" "-"
elif [[ -d "$SKILLS_DIR/hyperframes" ]]; then
  ok "hyperframes skills already at $SKILLS_DIR/hyperframes"; record "HyperFrames skills" "present" "$SKILLS_DIR"
else
  CMD=(npx -y skills add heygen-com/hyperframes -a claude-code -s '*' -y --copy)
  [[ $GLOBAL -eq 1 ]] && CMD+=(-g)
  if run "install HyperFrames skills" "${CMD[@]}"; then
    did "hyperframes skills installed → $SKILLS_DIR"; record "HyperFrames skills" "$(status_installed)" "$SKILLS_DIR"
  else
    fail "hyperframes skills install failed"; FAILURES+=("hyperframes"); record "HyperFrames skills" "FAILED" "-"
  fi
fi

# ---------------------------------------------------------------- d. ui ux pro max
if [[ $SKIP_UIPRO -eq 1 ]]; then
  skip "ui-ux-pro-max (--skip-uipro)"; record "UI UX Pro Max" "skipped" "-"
elif [[ -d "$SKILLS_DIR/ui-ux-pro-max" ]]; then
  ok "ui-ux-pro-max already at $SKILLS_DIR/ui-ux-pro-max"; record "UI UX Pro Max" "present" "$SKILLS_DIR"
else
  CMD=(npx -y ui-ux-pro-max-cli init --ai claude)
  [[ $GLOBAL -eq 1 ]] && CMD+=(--global)
  if run "install UI UX Pro Max skill" "${CMD[@]}"; then
    did "ui-ux-pro-max installed → $SKILLS_DIR"; record "UI UX Pro Max" "$(status_installed)" "$SKILLS_DIR"
  else
    fail "ui-ux-pro-max install failed"; FAILURES+=("ui-ux-pro-max"); record "UI UX Pro Max" "FAILED" "-"
  fi
fi

# ---------------------------------------------------------------- e. frontend-design plugin
if [[ $SKIP_FD -eq 1 ]]; then
  skip "frontend-design (--skip-frontend-design)"; record "frontend-design plugin" "skipped" "-"
elif [[ $HAS_CLAUDE -eq 0 ]]; then
  skip "frontend-design: claude CLI not found"; record "frontend-design plugin" "skipped (no claude)" "-"
elif [[ $DRY -eq 0 ]] && claude plugin list 2>/dev/null | grep -q 'frontend-design'; then
  ok "frontend-design plugin already installed"; record "frontend-design plugin" "present" "claude plugins"
else
  if run "install Anthropic frontend-design plugin" claude plugin install frontend-design@claude-plugins-official; then
    did "frontend-design plugin installed"; record "frontend-design plugin" "$(status_installed)" "claude plugins"
  else
    fail "frontend-design plugin install failed"; FAILURES+=("frontend-design"); record "frontend-design plugin" "FAILED" "-"
  fi
fi

# ---------------------------------------------------------------- e2. impeccable plugin
if [[ $SKIP_IMP -eq 1 ]]; then
  skip "impeccable (--skip-impeccable)"; record "Impeccable plugin" "skipped" "-"
elif [[ $HAS_CLAUDE -eq 0 ]]; then
  skip "impeccable: claude CLI not found"; record "Impeccable plugin" "skipped (no claude)" "-"
elif [[ $DRY -eq 0 ]] && claude plugin list 2>/dev/null | grep -q 'impeccable'; then
  ok "impeccable plugin already installed"; record "Impeccable plugin" "present" "claude plugins"
else
  IMP_OK=1
  if [[ $DRY -eq 1 ]] || ! claude plugin marketplace list 2>/dev/null | grep -q 'impeccable'; then
    run "add Impeccable marketplace" claude plugin marketplace add pbakaus/impeccable || IMP_OK=0
  fi
  if [[ $IMP_OK -eq 1 ]] && run "install Impeccable plugin" claude plugin install impeccable@impeccable; then
    did "impeccable plugin installed"; record "Impeccable plugin" "$(status_installed)" "claude plugins (impeccable)"
  else
    fail "impeccable plugin install failed"; FAILURES+=("impeccable"); record "Impeccable plugin" "FAILED" "-"
  fi
fi

# ---------------------------------------------------------------- f. 21st.dev MCP
if [[ $SKIP_21ST -eq 1 ]]; then
  skip "21st MCP (--skip-21st)"; record "21st.dev MCP" "skipped" "-"
elif [[ $HAS_CLAUDE -eq 0 ]]; then
  skip "21st MCP: claude CLI not found"; record "21st.dev MCP" "skipped (no claude)" "-"
elif [[ $DRY -eq 0 ]] && claude mcp list 2>/dev/null | grep -Eq '^21st[: ]'; then
  ok "21st MCP already registered"; record "21st.dev MCP" "present" "claude mcp (user scope)"
elif [[ -z "$KEY_21ST" ]]; then
  skip "21st MCP: no key. Get a free key at https://21st.dev/mcp then rerun with --21st-key <key> or export TWENTY_FIRST_API_KEY"
  record "21st.dev MCP" "skipped (no key)" "-"
else
  # User scope: the key lives in ~/.claude.json, never in the project → never committed.
  if run "register 21st MCP (user scope)" claude mcp add --transport http --scope user \
       --header "x-api-key: $KEY_21ST" 21st https://21st.dev/api/mcp; then
    did "21st MCP registered (user scope)"; record "21st.dev MCP" "$(status_installed)" "claude mcp (user scope)"
  else
    fail "21st MCP registration failed"; FAILURES+=("21st"); record "21st.dev MCP" "FAILED" "-"
  fi
fi

# ---------------------------------------------------------------- g. summary
echo
echo "[hyperui] summary"
printf '  %-24s %-24s %s\n' "component" "status" "where"
printf '  %-24s %-24s %s\n' "------------------------" "------------------------" "-----"
for row in "${SUMMARY[@]}"; do
  IFS='|' read -r c s w <<<"$row"
  printf '  %-24s %-24s %s\n' "$c" "$s" "$w"
done
echo
echo "[hyperui] Try: /hyperui:design (design brief), /hyperframes (video), /ui-ux-pro-max, /frontend-design, /impeccable audit"

if [[ ${#FAILURES[@]} -gt 0 ]]; then
  echo "[hyperui] ✗ failed steps: ${FAILURES[*]}"
  exit 1
fi
