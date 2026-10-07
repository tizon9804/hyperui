#!/usr/bin/env bash
# hyperui telemetry — opt-in, anonymous, per machine. Default OFF until `consent yes` once.
#
#   telemetry.sh status                      consent: yes|no|unasked · install_id · queued · last_flush
#   telemetry.sh consent yes|no              store the answer in user.md (first yes mints install_id), flush
#   telemetry.sh event <name> <skill> [k=v…] queue one event (only with consent; allowlist enforced)
#   telemetry.sh flush [--force] [--verbose] POST the queue once a day (or --force); silent, exit 0 always
#   telemetry.sh purge                       delete the queue and the install_id, set consent no
#
# Data dir: ~/.claude/plugins/data/hyperui (HYPERUI_DATA overrides): user.md keys telemetry,
# telemetry_asked_at, telemetry_last_flush, telemetry_last_feedback_at, install_id; queue telemetry.jsonl.
# Endpoint: HYPERUI_TELEMETRY_URL (default https://tizonai.com/api/telemetry), curl --max-time 3, ≤ 50
# events per request, 202 → queue truncated; anything else → kept for the next day. Never sends prompts,
# code, names, paths, URLs or emails: the only free text is the feedback comment (≤ 280 chars, scrubbed).
set -u
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"
DATA_DIR="${HYPERUI_DATA:-$HOME/.claude/plugins/data/hyperui}"
QUEUE="$DATA_DIR/telemetry.jsonl"; USER_FILE="$DATA_DIR/user.md"
URL="${HYPERUI_TELEMETRY_URL:-https://tizonai.com/api/telemetry}"
PROFILE="$PLUGIN_ROOT/scripts/profile.sh"
command -v python3 >/dev/null 2>&1 || exit 0

uget() { HYPERUI_DATA="$DATA_DIR" "$PROFILE" user-get "$1" 2>/dev/null || true; }
uset() { HYPERUI_DATA="$DATA_DIR" "$PROFILE" user-set "$1" "$2" >/dev/null 2>&1 || true; }
now()  { date -u +%Y-%m-%dT%H:%M:%SZ; }
consent() { local c; c="$(uget telemetry)"; case "$c" in yes|no) echo "$c" ;; *) echo unasked ;; esac; }
queued()  { local n=0; [ -f "$QUEUE" ] && n="$(grep -c . "$QUEUE" 2>/dev/null)"; echo "${n:-0}"; }
# del_key <key>: remove a top-level key line from user.md (profile.sh has no delete).
del_key() { [ -f "$USER_FILE" ] && python3 - "$1" "$USER_FILE" <<'PY'
import sys; k, f = sys.argv[1], sys.argv[2]
lines = open(f).read().split("\n"); open(f, "w").write("\n".join(l for l in lines if not l.startswith(k + ":")))
PY
}

cmd_status() {
  printf 'consent: %s\ninstall_id: %s\nqueued: %s\nlast_flush: %s\n' "$(consent)" "$(uget install_id)" "$(queued)" "$(uget telemetry_last_flush)"
}

cmd_consent() {
  case "${1:-}" in yes|no) ;; *) echo "telemetry.sh: consent yes|no" >&2; exit 1 ;; esac
  uset telemetry "$1"; uset telemetry_asked_at "$(now)"
  if [ "$1" = yes ] && [ -z "$(uget install_id)" ]; then
    local id; id="$(uuidgen 2>/dev/null | tr 'A-Z' 'a-z')"
    [ -n "$id" ] || id="$(python3 -c 'import uuid; print(uuid.uuid4())')"
    uset install_id "$id"
  fi
  [ "$1" = yes ] && cmd_flush --force
  echo "telemetry: $1"
}

# event <name> <skill> [k=v …] — python validates against the allowlist and prints the JSON line (or nothing).
cmd_event() {
  [ "$(consent)" = yes ] || exit 0
  [ $# -ge 2 ] || { echo "telemetry.sh: event <name> <skill> [k=v ...]" >&2; exit 1; }
  local line; line="$(TS="$(now)" python3 - "$@" <<'PY'
import json, os, re, sys
NAMES = {"unit_closed", "feedback", "gate_failed", "critique", "update_offer"}
ENUM = {"outcome": {"continue", "do_all", "fix", "stop"}, "rating": {"up", "down"}, "archetype": {"non-tech", "dev", "senior"}}
name, skill, kvs = sys.argv[1], sys.argv[2], sys.argv[3:]
if name not in NAMES or not re.fullmatch(r"[a-z][a-z0-9_-]{0,31}", skill): sys.exit(1)
props = {}
for kv in kvs:
    k, _, v = kv.partition("=")
    if k in ENUM and v in ENUM[k]: props[k] = v
    elif k == "iterations" and re.fullmatch(r"\d{1,4}", v): props[k] = int(v)
    elif k == "severity_max" and v in list("01234"): props[k] = int(v)
    elif k == "accepted" and v in ("true", "false"): props[k] = v == "true"
    elif k == "comment" and name == "feedback":
        v = re.sub(r"\S*(://|/|\\|~|@)\S*", "", v)          # URLs, paths, home refs, emails
        v = re.sub(r"\s+", " ", v).strip()[:280]
        if v: props[k] = v
print(json.dumps({"ts": os.environ["TS"], "name": name, "skill": skill, "props": props}, ensure_ascii=False))
PY
)" || { echo "telemetry.sh: event rejected (unknown name or bad skill)" >&2; exit 1; }
  mkdir -p "$DATA_DIR" && printf '%s\n' "$line" >> "$QUEUE"
}

cmd_flush() {
  local force=0 verbose=0; for a in "$@"; do case "$a" in --force) force=1 ;; --verbose) verbose=1 ;; esac; done
  say() { [ "$verbose" -eq 1 ] && echo "telemetry.sh: $*" >&2; return 0; }
  [ "$(consent)" = yes ] || { say "no consent"; exit 0; }
  [ "$(queued)" -gt 0 ] || { say "queue empty"; exit 0; }
  if [ "$force" -eq 0 ]; then
    local last; last="$(uget telemetry_last_flush)"
    if [ -n "$last" ] && python3 -c 'import sys,time,calendar; t=calendar.timegm(time.strptime(sys.argv[1],"%Y-%m-%dT%H:%M:%SZ")); sys.exit(0 if time.time()-t < 86400 else 1)' "$last" 2>/dev/null; then
      say "flushed less than 24 h ago"; exit 0
    fi
  fi
  local ver os cv; ver="$(sed -nE 's/.*"version"[[:space:]]*:[[:space:]]*"([^"]*)".*/\1/p' "$PLUGIN_ROOT/.claude-plugin/plugin.json" | head -n1)"
  os="$(uname -s | tr 'A-Z' 'a-z')"; cv="$(claude --version 2>/dev/null | grep -oE '[0-9]+\.[0-9]+\.[0-9]+' | head -n1)"
  local rounds=0 body code
  while [ "$(queued)" -gt 0 ] && [ "$rounds" -lt 5 ]; do
    rounds=$((rounds + 1))
    body="$(python3 - "$QUEUE" "$(uget install_id)" "$ver" "$os" "${cv:-unknown}" <<'PY'
import json, sys
events = [json.loads(l) for l in open(sys.argv[1]) if l.strip()][:50]
print(json.dumps({"install_id": sys.argv[2], "plugin_version": sys.argv[3], "os": sys.argv[4], "claude_version": sys.argv[5], "events": events}, ensure_ascii=False))
PY
)" || exit 0
    code="$(printf '%s' "$body" | curl -sS -o /dev/null -w '%{http_code}' --max-time 3 -H 'Content-Type: application/json' -X POST --data-binary @- "$URL" 2>/dev/null)" || code=000
    case "$code" in
      2??) say "sent $(printf '%s' "$body" | python3 -c 'import json,sys; print(len(json.load(sys.stdin)["events"]))') event(s) → $code"
           tail -n +51 "$QUEUE" > "$QUEUE.tmp" 2>/dev/null; mv -f "$QUEUE.tmp" "$QUEUE"; uset telemetry_last_flush "$(now)" ;;
      *)   say "endpoint answered $code; queue kept ($(queued))"; exit 0 ;;
    esac
  done
  exit 0
}

cmd_purge() { rm -f "$QUEUE" "$QUEUE.tmp"; del_key install_id; del_key telemetry_last_flush; uset telemetry no; echo "telemetry: purged, consent no"; }

case "${1:-}" in
  status)  cmd_status ;;
  consent) shift; cmd_consent "$@" ;;
  event)   shift; cmd_event "$@" ;;
  flush)   shift; cmd_flush "$@" ;;
  purge)   cmd_purge ;;
  *) sed -n '2,15p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; exit 2 ;;
esac
