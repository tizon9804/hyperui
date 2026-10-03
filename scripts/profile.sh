#!/usr/bin/env bash
# hyperui memory helper: reads/writes the YAML frontmatter of .hyperui/profile.md
# and ${CLAUDE_PLUGIN_DATA}/user.md. No dependencies beyond python3 (awk fallback).
#
# Usage:
#   profile.sh init [--private]        copy seed templates into .hyperui/ (never overwrites)
#   profile.sh get <dotted.key>        print a value (lists as comma-separated)
#   profile.sh set <dotted.key> <value> create/update a key (value with commas -> list)
#   profile.sh private                 add .hyperui/ to .gitignore, set private: true
#   profile.sh user-get <key>          read ${CLAUDE_PLUGIN_DATA}/user.md
#   profile.sh user-set <key> <value>  write ${CLAUDE_PLUGIN_DATA}/user.md
#   profile.sh path                    print the .hyperui directory
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$PWD}"
HYPERUI_DIR="$PROJECT_DIR/.hyperui"
PROFILE="$HYPERUI_DIR/profile.md"
DATA_DIR="${CLAUDE_PLUGIN_DATA:-$HOME/.claude/plugins/data/hyperui}"
USER_FILE="$DATA_DIR/user.md"

die() { echo "profile.sh: $*" >&2; exit 1; }

usage() { sed -n '2,13p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

have_python() { command -v python3 >/dev/null 2>&1; }

# ---------------------------------------------------------------- python core
PY_CORE='
import sys, re, os

def split_doc(text):
    lines = text.split("\n")
    if lines and lines[0].strip() == "---":
        for i in range(1, len(lines)):
            if lines[i].strip() == "---":
                return lines[1:i], "\n".join(lines[i+1:])
    return None, text

def indent_of(line):
    return len(line) - len(line.lstrip(" "))

def strip_comment(v):
    out, q = [], None
    for i, c in enumerate(v):
        if q:
            if c == q: q = None
        elif c in "\"\x27":
            q = c
        elif c == "#" and (i == 0 or v[i-1] in " \t"):
            break
        out.append(c)
    return "".join(out).strip()

def comment_pos(line):
    """Index of a trailing # comment on a key line (outside quotes), or None."""
    m = KEY_RE.match(line)
    if not m:
        return None
    off = m.start(4)
    v = m.group(4)
    q = None
    for i, c in enumerate(v):
        if q:
            if c == q: q = None
        elif c in "\"\x27":
            q = c
        elif c == "#" and (i == 0 or v[i-1] in " \t"):
            return off + i
    return None

def unquote(s):
    s = s.strip()
    if len(s) >= 2 and s[0] == s[-1] and s[0] in "\"\x27":
        return s[1:-1]
    return s

def split_flow(inner):
    parts, depth, q, cur = [], 0, None, ""
    for c in inner:
        if q:
            cur += c
            if c == q: q = None
            continue
        if c in "\"\x27": q = c
        elif c in "[{": depth += 1
        elif c in "]}": depth -= 1
        if c == "," and depth == 0:
            parts.append(cur); cur = ""
        else:
            cur += c
    if cur.strip(): parts.append(cur)
    return [p.strip() for p in parts]

KEY_RE = re.compile(r"^(\s*)([^\s#:][^:]*?):(\s+|$)(.*)$")

def find(fm, path):
    """Return (index_of_line, indent) of the dotted path, or partial info."""
    start, end, base = 0, len(fm), 0
    idx = None
    for depth, key in enumerate(path):
        found = None
        i = start
        level = None
        while i < end:
            line = fm[i]
            if not line.strip() or line.lstrip().startswith("#"):
                i += 1; continue
            ind = indent_of(line)
            if level is None:
                level = ind
            if ind < level:
                break
            if ind == level:
                m = KEY_RE.match(line)
                if m and unquote(m.group(2)) == key:
                    found = i; break
            i += 1
        if found is None:
            return None, depth, start, end, (level if level is not None else base)
        idx = found
        ind = indent_of(fm[found])
        # child block: following lines with greater indent
        j = found + 1
        while j < end and (not fm[j].strip() or indent_of(fm[j]) > ind or fm[j].lstrip().startswith("#") and indent_of(fm[j]) > ind):
            j += 1
        # trim trailing blank lines from block
        while j > found + 1 and not fm[j-1].strip():
            j -= 1
        start, end, base = found + 1, j, ind + 2
    return idx, len(path), start, end, base

def block_end(fm, i):
    ind = indent_of(fm[i])
    j = i + 1
    while j < len(fm) and (not fm[j].strip() or indent_of(fm[j]) > ind):
        j += 1
    while j > i + 1 and not fm[j-1].strip():
        j -= 1
    return j

def render_value(raw):
    v = strip_comment(raw)
    if v.startswith("[") and v.endswith("]"):
        return ",".join(unquote(p) for p in split_flow(v[1:-1]))
    if v.startswith("{") and v.endswith("}"):
        return ",".join(unquote(p) for p in split_flow(v[1:-1]))
    return unquote(v)

def cmd_get(path_str, fname):
    if not os.path.exists(fname):
        sys.exit(1)
    fm, _ = split_doc(open(fname, encoding="utf-8").read())
    if fm is None:
        sys.exit(1)
    path = path_str.split(".")
    # support inline maps on the way down: a.b.c where a.b is "{ c: x }"
    for cut in range(len(path), 0, -1):
        idx, depth, s, e, _ = find(fm, path[:cut])
        if idx is not None and depth == cut:
            m = KEY_RE.match(fm[idx])
            val = strip_comment(m.group(4))
            rest = path[cut:]
            if not rest:
                if val == "" or val in ("|", ">"):
                    # block list or nested map
                    items = []
                    for line in fm[idx+1:block_end(fm, idx)]:
                        t = line.strip()
                        if t.startswith("- "):
                            items.append(unquote(strip_comment(t[2:])))
                    if items:
                        print(",".join(items)); return
                    if val == "":
                        sys.exit(1)
                print(render_value(val)); return
            if val.startswith("{") and val.endswith("}"):
                cur = val
                for k in rest:
                    if not (cur.startswith("{") and cur.endswith("}")):
                        sys.exit(1)
                    found = None
                    for p in split_flow(cur[1:-1]):
                        kk, _, vv = p.partition(":")
                        if unquote(kk) == k:
                            found = vv.strip(); break
                    if found is None:
                        sys.exit(1)
                    cur = found
                print(render_value(cur)); return
            sys.exit(1)
    sys.exit(1)

PLAIN_OK = re.compile(r"^[^\s\[\]{}&*!|>\x27\"%@`#,?:-][^#]*$")

def fmt_scalar(v):
    v = v.strip()
    if v == "":
        return "\"\""
    if (PLAIN_OK.match(v) and ": " not in v and not v.endswith(":")) or re.match(r"^-?\d+(\.\d+)?$", v):
        return v
    return "\"" + v.replace("\\", "\\\\").replace("\"", "\\\"") + "\""

def fmt_value(v):
    if "," in v:
        return "[" + ", ".join(fmt_scalar(p) for p in v.split(",") if p.strip()) + "]"
    return fmt_scalar(v)

def expand_inline_map(fm, idx):
    m = KEY_RE.match(fm[idx])
    ind = indent_of(fm[idx])
    val = strip_comment(m.group(4))
    new = [" " * ind + m.group(2) + ":"]
    for p in split_flow(val[1:-1]):
        kk, _, vv = p.partition(":")
        new.append(" " * (ind + 2) + kk.strip() + ": " + vv.strip())
    fm[idx:idx+1] = new

def cmd_set(path_str, value, fname):
    text = open(fname, encoding="utf-8").read() if os.path.exists(fname) else ""
    fm, body = split_doc(text)
    if fm is None:
        fm, body = [], text
    path = path_str.split(".")
    while True:
        idx, depth, s, e, base = find(fm, path)
        if idx is not None and depth == len(path):
            m = KEY_RE.match(fm[idx])
            # drop an old nested block / block list under the key
            end = block_end(fm, idx)
            fm[idx+1:end] = []
            orig = fm[idx]
            cpos = comment_pos(orig)
            line = " " * indent_of(orig) + m.group(2) + ": " + fmt_value(value)
            if cpos is not None:
                line = line.ljust(cpos - 1) + " " + orig[cpos:]
            fm[idx] = line
            break
        # parent exists (depth > 0) but is an inline map or a scalar -> convert to block
        if depth > 0:
            pidx, _, _, _, _ = find(fm, path[:depth])
            pm = KEY_RE.match(fm[pidx])
            pval = strip_comment(pm.group(4))
            if pval.startswith("{") and pval.endswith("}"):
                expand_inline_map(fm, pidx); continue
            if pval != "":
                fm[pidx] = " " * indent_of(fm[pidx]) + pm.group(2) + ":"
                s = e = pidx + 1
                base = indent_of(fm[pidx]) + 2
        insert_at = e if depth > 0 else len(fm)
        if depth == 0:
            # top level: append before trailing blank lines
            while insert_at > 0 and not fm[insert_at-1].strip():
                insert_at -= 1
            base = 0
        new = []
        for k in range(depth, len(path)):
            ind = base + 2 * (k - depth)
            if k == len(path) - 1:
                new.append(" " * ind + path[k] + ": " + fmt_value(value))
            else:
                new.append(" " * ind + path[k] + ":")
        fm[insert_at:insert_at] = new
        break
    out = "---\n" + "".join(l + "\n" for l in fm) + "---\n" + body
    tmp = fname + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(out)
    os.replace(tmp, fname)

if __name__ == "__main__":
    op = sys.argv[1]
    if op == "get":
        cmd_get(sys.argv[2], sys.argv[3])
    elif op == "set":
        cmd_set(sys.argv[2], sys.argv[3], sys.argv[4])
'

# ---------------------------------------------------------------- awk fallback
# Handles top-level and one-level nested keys (a or a.b), scalars and inline lists.
awk_get() { # key file
  awk -v key="$1" '
    BEGIN { n = split(key, p, "."); infm = 0; parent = "" }
    NR == 1 && $0 ~ /^---[ \t]*$/ { infm = 1; next }
    infm && $0 ~ /^---[ \t]*$/ { exit }
    !infm { exit }
    {
      line = $0; ind = match(line, /[^ ]/) - 1
      if (line ~ /^[ \t]*(#|$)/) next
      k = line; sub(/^[ \t]*/, "", k); v = k; sub(/:.*/, "", k)
      if (index(v, ":") == 0) next
      sub(/^[^:]*:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v)
      if (ind == 0) parent = k
      full = (ind == 0) ? k : parent "." k
      if (full == key && v != "") {
        if (v ~ /^\[.*\]$/) { v = substr(v, 2, length(v) - 2); gsub(/[ \t]*,[ \t]*/, ",", v) }
        gsub(/^["\x27]|["\x27]$/, "", v); print v; found = 1; exit
      }
    }
    END { exit found ? 0 : 1 }' "$2"
}

awk_set() { # key value file
  local key="$1" val="$2" file="$3" tmp
  [[ "$val" == *,* ]] && val="[$(echo "$val" | sed 's/[[:space:]]*,[[:space:]]*/, /g')]"
  [ -f "$file" ] || printf -- '---\n---\n' > "$file"
  head -1 "$file" | grep -q '^---' || { tmp="$(mktemp)"; { printf -- '---\n---\n'; cat "$file"; } > "$tmp"; mv "$tmp" "$file"; }
  tmp="$(mktemp)"
  awk -v key="$key" -v val="$val" '
    BEGIN { n = split(key, p, "."); infm = 0; done = 0; parent = ""; inparent = 0 }
    NR == 1 && /^---/ { print; infm = 1; next }
    infm && /^---[ \t]*$/ {
      if (!done) {
        if (n == 1) print key ": " val
        else if (inparent) print "  " p[2] ": " val
        else { print p[1] ":"; print "  " p[2] ": " val }
      }
      infm = 0; done = 1; print; next
    }
    infm {
      ind = match($0, /[^ ]/) - 1; k = $0; sub(/^[ \t]*/, "", k); sub(/:.*/, "", k)
      if (ind == 0 && $0 !~ /^[ \t]*(#|$)/) {
        if (inparent && !done && n == 2) { print "  " p[2] ": " val; done = 1 }
        inparent = (n == 2 && k == p[1]); parent = k
        if (n == 1 && k == p[1] && !done) { print key ": " val; done = 1; next }
      } else if (ind > 0 && inparent && n == 2 && k == p[2] && !done) {
        print "  " p[2] ": " val; done = 1; next
      }
    }
    { print }' "$file" > "$tmp" && mv "$tmp" "$file"
}

fm_get() { # key file
  [ -f "$2" ] || return 1
  if have_python; then python3 -c "$PY_CORE" get "$1" "$2"; else awk_get "$1" "$2"; fi
}

fm_set() { # key value file
  mkdir -p "$(dirname "$3")"
  if have_python; then python3 -c "$PY_CORE" set "$1" "$2" "$3"; else awk_set "$1" "$2" "$3"; fi
}

# ---------------------------------------------------------------- commands
cmd_init() {
  local private=0
  [ "${1:-}" = "--private" ] && private=1
  mkdir -p "$HYPERUI_DIR"
  local src="$PLUGIN_ROOT/templates/hyperui" f name copied=0
  if [ -d "$src" ]; then
    for f in "$src"/*.md; do
      [ -e "$f" ] || continue
      name="$(basename "$f")"
      if [ ! -e "$HYPERUI_DIR/$name" ]; then cp "$f" "$HYPERUI_DIR/$name"; copied=$((copied + 1)); fi
    done
  else
    echo "profile.sh: no templates at $src; created an empty .hyperui/" >&2
  fi
  [ -e "$PROFILE" ] || printf -- '---\nhyperui: 1\n---\n' > "$PROFILE"
  echo "initialized $HYPERUI_DIR ($copied file(s) copied)"
  [ "$private" -eq 1 ] && cmd_private
  return 0
}

cmd_private() {
  mkdir -p "$HYPERUI_DIR"
  local gi="$PROJECT_DIR/.gitignore"
  if [ -f "$gi" ] && grep -qxE '/?\.hyperui/?' "$gi"; then
    :
  else
    if [ -s "$gi" ] && [ -n "$(tail -c1 "$gi")" ]; then echo >> "$gi"; fi
    echo ".hyperui/" >> "$gi"
  fi
  fm_set private true "$PROFILE"
  echo "private: .hyperui/ is git-ignored"
}

ensure_user_file() {
  mkdir -p "$DATA_DIR"
  [ -f "$USER_FILE" ] || printf -- '---\n---\n' > "$USER_FILE"
}

cmd="${1:-}"
[ $# -gt 0 ] && shift
case "$cmd" in
  init)     cmd_init "$@" ;;
  get)      [ $# -eq 1 ] || die "usage: get <dotted.key>"; fm_get "$1" "$PROFILE" ;;
  set)      [ $# -eq 2 ] || die "usage: set <dotted.key> <value>"
            [ -d "$HYPERUI_DIR" ] || mkdir -p "$HYPERUI_DIR"
            [ -f "$PROFILE" ] || printf -- '---\nhyperui: 1\n---\n' > "$PROFILE"
            fm_set "$1" "$2" "$PROFILE" ;;
  private)  cmd_private ;;
  user-get) [ $# -eq 1 ] || die "usage: user-get <key>"; ensure_user_file; fm_get "$1" "$USER_FILE" ;;
  user-set) [ $# -eq 2 ] || die "usage: user-set <key> <value>"; ensure_user_file; fm_set "$1" "$2" "$USER_FILE" ;;
  path)     echo "$HYPERUI_DIR" ;;
  -h|--help|help|"") usage ;;
  *)        die "unknown command: $cmd (try --help)" ;;
esac
