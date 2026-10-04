#!/usr/bin/env bash
# Daily update check for hyperui. Called by welcome.sh (SessionStart) and by the entry skill.
#
#   update-check.sh                 print one JSON line:
#       {"installed":"x","latest":"y","update_available":true|false,"declined":"y"|null,"whats_new":"…"|null}
#   update-check.sh --decline <v>   remember that the user said "later" for version <v>; prints the same JSON
#
# Installed version: ${CLAUDE_PLUGIN_ROOT}/.claude-plugin/plugin.json. Cache (24 h):
# ~/.claude/plugins/data/hyperui/update-check.json = {checked_at, latest, declined, whats_new}
# (HYPERUI_DATA overrides the directory, like profile.sh). The remote manifest is fetched with
# curl (3 s timeout) from HYPERUI_UPDATE_URL (default: the raw plugin.json on GitHub main); the
# CHANGELOG top bullet is fetched only when an update exists (HYPERUI_CHANGELOG_URL). Any network
# or parse error is silent: the cache (if any) is reused, latest falls back to installed, exit 0.
# python3 is optional (awk/sed fallback for the tiny JSON involved).
set -u

PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DATA_DIR="${HYPERUI_DATA:-$HOME/.claude/plugins/data/hyperui}"
CACHE="$DATA_DIR/update-check.json"
UPDATE_URL="${HYPERUI_UPDATE_URL:-https://raw.githubusercontent.com/tizonai/hyperui/main/.claude-plugin/plugin.json}"
CHANGELOG_URL="${HYPERUI_CHANGELOG_URL:-https://raw.githubusercontent.com/tizonai/hyperui/main/CHANGELOG.md}"
TTL="${HYPERUI_UPDATE_TTL:-86400}"

# json_str <key> <text>  — read "key": "value" from a one-level JSON text (null → empty).
json_str() {
  printf '%s' "$2" | tr -d '\n' | sed -nE 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' | head -n1
}
# json_num <key> <text> — read "key": 123 (unquoted number) from the same kind of text.
json_num() {
  printf '%s' "$2" | tr -d '\n' | sed -nE 's/.*"'"$1"'"[[:space:]]*:[[:space:]]*([0-9]+).*/\1/p' | head -n1
}
# fetch <url>  — body on stdout, or nothing (never fails the script). file:// and plain paths allowed for tests.
fetch() {
  case "$1" in
    http://*|https://*) curl -fsSL --max-time 3 "$1" 2>/dev/null || true ;;
    file://*) cat "${1#file://}" 2>/dev/null || true ;;
    *) cat "$1" 2>/dev/null || true ;;
  esac
}
# esc <text> — JSON-escape backslash, double quote, control chars; strips newlines.
esc() { printf '%s' "$1" | tr -d '\n\r' | sed -e 's/\\/\\\\/g' -e 's/"/\\"/g' -e 's/\t/ /g'; }
# vgt <a> <b> — true when a > b (dotted numeric versions; non-numeric parts compared as text).
vgt() {
  [ "$1" = "$2" ] && return 1
  local hi; hi="$(printf '%s\n%s\n' "$1" "$2" | sort -t. -k1,1n -k2,2n -k3,3n -k4,4n | tail -n1)"
  [ "$hi" = "$1" ]
}
# whats_new <changelog text> — first bullet of the top "## x.y.z" section, markdown markers removed,
# quotes/backslashes dropped (keeps the cache a one-level JSON that sed can re-read), ≤ 160 chars.
whats_new() {
  printf '%s\n' "$1" | awk '/^## /{n++} n==1 && /^- /{print; exit}' \
    | sed -E 's/^- //; s/\*\*//g; s/`//g' | tr -d '\\' | tr '"' "'" | cut -c1-160
}

INSTALLED="$(json_str version "$(cat "$PLUGIN_ROOT/.claude-plugin/plugin.json" 2>/dev/null || true)")"
[ -n "$INSTALLED" ] || INSTALLED="0.0.0"

CACHED=""; [ -f "$CACHE" ] && CACHED="$(cat "$CACHE" 2>/dev/null || true)"
CHECKED_AT="$(json_num checked_at "$CACHED")"
LATEST="$(json_str latest "$CACHED")"
DECLINED="$(json_str declined "$CACHED")"
WHATS_NEW="$(json_str whats_new "$CACHED")"

NOW="$(date +%s)"
case "$CHECKED_AT" in ''|*[!0-9]*) CHECKED_AT=0 ;; esac
FRESH=0
if [ -n "$LATEST" ] && [ $((NOW - CHECKED_AT)) -lt "$TTL" ] && [ $((NOW - CHECKED_AT)) -ge 0 ]; then FRESH=1; fi

if [ "${1:-}" = "--decline" ]; then
  DECLINED="${2:-$LATEST}"
elif [ "$FRESH" -eq 0 ]; then
  REMOTE="$(json_str version "$(fetch "$UPDATE_URL")")"
  if [ -n "$REMOTE" ]; then
    LATEST="$REMOTE"; CHECKED_AT="$NOW"; WHATS_NEW=""
    if vgt "$LATEST" "$INSTALLED"; then
      WHATS_NEW="$(whats_new "$(fetch "$CHANGELOG_URL")")"
    fi
  fi
fi
[ -n "$LATEST" ] || LATEST="$INSTALLED"

AVAILABLE=false
if vgt "$LATEST" "$INSTALLED"; then AVAILABLE=true; fi

mkdir -p "$DATA_DIR" 2>/dev/null || true
DECL_JSON=null; [ -n "$DECLINED" ] && DECL_JSON="\"$(esc "$DECLINED")\""
NEW_JSON=null; [ -n "$WHATS_NEW" ] && NEW_JSON="\"$(esc "$WHATS_NEW")\""
printf '{"checked_at":%s,"latest":"%s","declined":%s,"whats_new":%s}\n' "$CHECKED_AT" "$(esc "$LATEST")" "$DECL_JSON" "$NEW_JSON" > "$CACHE" 2>/dev/null || true

printf '{"installed":"%s","latest":"%s","update_available":%s,"declined":%s,"whats_new":%s}\n' \
  "$(esc "$INSTALLED")" "$(esc "$LATEST")" "$AVAILABLE" "$DECL_JSON" "$NEW_JSON"
exit 0
