#!/usr/bin/env bash
# Verify that a deployed site serves the expected version (ship skill: "Verify the deploy").
#
# Usage: verify-deploy.sh <url> <expected-version> [--timeout <seconds>] [--interval <seconds>] [--once]
#   url               site origin or page, e.g. https://example.com (https:// is added when missing)
#   expected-version  x.y.z as in the project's version file (a leading "v" is ignored)
#   --timeout <s>     give up after this many seconds (default 600 = 10 min; hosts build asynchronously)
#   --interval <s>    seconds between polls (default 30)
#   --once            a single check, no polling (same as --timeout 0)
#
# Reads, in order: <url>/version.json ("version" field) -> <meta name="app-version" content="x.y.z+sha">
# in the HTML of <url> -> a text node "v<x.y.z>" (footer stamp; HTML comments such as React's
# "v<!-- -->0.3.1" are stripped first). Prints what it found on every poll and the JSON/meta/text it
# used. Exit 0 when the live version equals the expected one, 1 when the budget runs out (or --once
# fails), 2 on a usage error. Needs curl only.
set -uo pipefail

URL=""; EXPECTED=""; TIMEOUT=600; INTERVAL=30
while [[ $# -gt 0 ]]; do
  case "$1" in
    --timeout)  TIMEOUT="${2:-}"; shift 2 ;;
    --interval) INTERVAL="${2:-}"; shift 2 ;;
    --once)     TIMEOUT=0; shift ;;
    -h|--help)  sed -n '2,16p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 0 ;;
    -*)         echo "verify-deploy: unknown option $1" >&2; exit 2 ;;
    *)          if [[ -z "$URL" ]]; then URL="$1"; elif [[ -z "$EXPECTED" ]]; then EXPECTED="$1";
                else echo "verify-deploy: unexpected argument $1" >&2; exit 2; fi; shift ;;
  esac
done
[[ -n "$URL" && -n "$EXPECTED" ]] || { echo "usage: verify-deploy.sh <url> <expected-version> [--timeout <s>] [--interval <s>] [--once]" >&2; exit 2; }
command -v curl >/dev/null 2>&1 || { echo "verify-deploy: curl not found" >&2; exit 2; }
[[ "$TIMEOUT" =~ ^[0-9]+$ && "$INTERVAL" =~ ^[0-9]+$ ]] || { echo "verify-deploy: --timeout and --interval take whole seconds" >&2; exit 2; }
[[ "$INTERVAL" -ge 1 ]] || INTERVAL=1
[[ "$URL" =~ ^https?:// ]] || URL="https://$URL"
URL="${URL%/}"
EXPECTED="${EXPECTED#v}"

SEMVER='[0-9]+\.[0-9]+\.[0-9]+(-[0-9A-Za-z.-]+)?'
Q='["'"'"']'   # a double or single quote, for the HTML attribute patterns

fetch() { curl -sL --max-time 20 -H 'Cache-Control: no-cache' -H 'Pragma: no-cache' "$1" 2>/dev/null; }

# One probe. Sets FOUND (version or empty), SOURCE (version.json | meta | footer | none), DETAIL (what was seen).
probe() {
  FOUND=""; SOURCE="none"; DETAIL=""
  local body v m t
  body="$(fetch "$URL/version.json")"
  if [[ -n "$body" ]]; then
    v="$(printf '%s' "$body" | grep -oE '"version"[[:space:]]*:[[:space:]]*"[^"]+"' | head -n1 | sed -E 's/.*"([^"]+)"$/\1/')"
    if [[ -n "$v" ]]; then FOUND="${v#v}"; SOURCE="version.json"; DETAIL="$(printf '%s' "$body" | tr -d '\n' | cut -c1-200)"; return; fi
  fi
  body="$(fetch "$URL/" | sed -E 's/<!--[^>]*-->//g')"
  [[ -n "$body" ]] || return
  m="$(printf '%s' "$body" | grep -oiE "<meta[^>]+name=${Q}app-version${Q}[^>]*>" | head -n1)"
  if [[ -n "$m" ]]; then
    v="$(printf '%s' "$m" | grep -oiE "content=${Q}[^\"']+" | head -n1 | sed -E "s/^content=${Q}//")"
    if [[ -n "$v" ]]; then FOUND="${v%%+*}"; FOUND="${FOUND#v}"; SOURCE="meta"; DETAIL="$m"; return; fi
  fi
  t="$(printf '%s' "$body" | grep -oE ">v${SEMVER}<" | head -n1)"      # a text node: the footer stamp
  [[ -n "$t" ]] || t="$(printf '%s' "$body" | grep -oE "\\bv${SEMVER}\\b" | head -n1)"
  if [[ -n "$t" ]]; then t="${t#>}"; t="${t%<}"; FOUND="${t#v}"; SOURCE="footer"; DETAIL="$t"; fi
}

START=$(date +%s); ATTEMPT=0
while :; do
  ATTEMPT=$((ATTEMPT + 1)); probe
  ELAPSED=$(( $(date +%s) - START ))
  if [[ -n "$FOUND" ]]; then
    if [[ "$FOUND" == "$EXPECTED" ]]; then
      echo "deployed v$FOUND ✓ (source: $SOURCE · ${ELAPSED}s · $ATTEMPT check(s))"
      echo "  $DETAIL"
      exit 0
    fi
    echo "[$(date +%H:%M:%S)] live v$FOUND, expected v$EXPECTED (source: $SOURCE) — ${ELAPSED}s elapsed"
  else
    echo "[$(date +%H:%M:%S)] no version found at $URL (no /version.json, no <meta name=\"app-version\">, no v<x.y.z> text) — ${ELAPSED}s elapsed"
  fi
  if (( ELAPSED + INTERVAL > TIMEOUT )); then
    if [[ -n "$FOUND" ]]; then
      echo "still v$FOUND after ${ELAPSED}s (expected v$EXPECTED) → check the host's build log"
      echo "  $DETAIL"
    else
      echo "no version found after ${ELAPSED}s → add the version stamp (skills/design/references/version-stamp.md) or check the URL"
    fi
    exit 1
  fi
  sleep "$INTERVAL"
done
