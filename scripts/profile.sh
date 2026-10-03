#!/usr/bin/env bash
# hyperui memory helper: reads/writes the YAML frontmatter of <root>/.hyperui/profile.md
# and ~/.claude/plugins/data/hyperui/user.md (HYPERUI_DATA overrides). No dependencies beyond python3 (awk fallback).
#
# Usage:
#   profile.sh [--repo <path>] <command> ...
#   profile.sh init [--private]        copy seed templates into <root>/.hyperui/ (never overwrites)
#   profile.sh get <dotted.key>        print a value (lists as comma-separated)
#   profile.sh set <dotted.key> <value> create/update a key (value with commas -> list)
#   profile.sh private                 add .hyperui/ to <root>/.gitignore, set private: true
#   profile.sh user-get <key>          read the per-machine user.md
#   profile.sh user-set <key> <value>  write the per-machine user.md
#   profile.sh path                    print the .hyperui directory of the resolved root
#   profile.sh root                    print the primary project root (absolute)
#   profile.sh roots                   print every root, one per line (primary first)
#   profile.sh root-set [--replace] [--move] <path>...
#                                      remember <path>(s) as the root(s) for the current
#                                      directory; appends unless --replace; `root-set .`
#                                      forgets the mapping (= work on cwd); --move carries an
#                                      existing <cwd>/.hyperui/ into the first new root when
#                                      that root has none (onboarding started before the path)
#   profile.sh root-clear              forget the mapping for the current directory
#   profile.sh inspect [<root>]        print the repo's top-level files, stack markers and
#                                      manifest dependencies (works for a root outside cwd)
#
# Root resolution, first match wins: $HYPERUI_ROOT (colon-separated) -> --repo <path>
# (repeatable, any command) -> user.md `roots:` map (current directory -> repo or list) ->
# the current directory (${CLAUDE_PROJECT_DIR:-$PWD}). The first root is the primary one.
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$SCRIPT_DIR/.." && pwd)}"
CWD="${CLAUDE_PROJECT_DIR:-$PWD}"
# Per-machine file. One fixed path on purpose: hooks receive CLAUDE_PLUGIN_DATA (id-dependent,
# e.g. data/hyperui-tizonai) but Bash-tool commands never do, and both must read the same roots map.
DATA_DIR="${HYPERUI_DATA:-$HOME/.claude/plugins/data/hyperui}"
USER_FILE="$DATA_DIR/user.md"

die() { echo "profile.sh: $*" >&2; exit 1; }

usage() { sed -n '2,28p' "${BASH_SOURCE[0]}" | sed 's/^# \{0,1\}//'; }

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

# ---- roots map (user.md): `roots:` block of  "<cwd>": <repo>  lines
def roots_span(fm):
    idx, depth, s, e, _ = find(fm, ["roots"])
    if idx is None or depth != 1:
        return None
    return idx, s, e

def roots_items(fm):
    span = roots_span(fm)
    if not span:
        return []
    idx, s, e = span
    out = []
    for i in range(s, e):
        m = KEY_RE.match(fm[i])
        if m and fm[i].strip() and not fm[i].lstrip().startswith("#"):
            out.append((i, unquote(m.group(2)), render_value(m.group(4))))
    return out

def load_fm(fname):
    text = open(fname, encoding="utf-8").read() if os.path.exists(fname) else ""
    fm, body = split_doc(text)
    if fm is None:
        fm, body = [], text
    return fm, body

def save_fm(fm, body, fname):
    out = "---\n" + "".join(l + "\n" for l in fm) + "---\n" + body
    tmp = fname + ".tmp"
    with open(tmp, "w", encoding="utf-8") as f:
        f.write(out)
    os.replace(tmp, fname)

def cmd_root_get(cwd, fname):
    """Print the roots mapped to cwd, one per line (a scalar or a flow list in the file)."""
    if not os.path.exists(fname):
        sys.exit(1)
    fm, _ = load_fm(fname)
    for i, k, _ in roots_items(fm):
        if k == cwd:
            raw = strip_comment(KEY_RE.match(fm[i]).group(4))
            items = split_flow(raw[1:-1]) if raw.startswith("[") and raw.endswith("]") else [raw]
            items = [unquote(x) for x in items if unquote(x)]
            if not items:
                sys.exit(1)
            print("\n".join(items)); return
    sys.exit(1)

def cmd_root_set(cwd, repos, fname):
    """repos: newline-separated absolute paths; stored as a flow list."""
    fm, body = load_fm(fname)
    items = [r for r in repos.split("\n") if r]
    val = "[" + ", ".join(fmt_scalar(r) for r in items) + "]"
    line = "  \"" + cwd.replace("\\", "\\\\").replace("\"", "\\\"") + "\": " + val
    for i, k, _ in roots_items(fm):
        if k == cwd:
            fm[i] = line; save_fm(fm, body, fname); return
    span = roots_span(fm)
    if span:
        idx, s, e = span
        fm[idx] = " " * indent_of(fm[idx]) + "roots:"   # drop a scalar/inline value if any
        fm[e:e] = [line]
    else:
        at = len(fm)
        while at > 0 and not fm[at-1].strip():
            at -= 1
        fm[at:at] = ["roots:", line]
    save_fm(fm, body, fname)

def cmd_root_del(cwd, fname):
    if not os.path.exists(fname):
        return
    fm, body = load_fm(fname)
    for i, k, _ in roots_items(fm):
        if k == cwd:
            del fm[i]
            span = roots_span(fm)
            if span and span[1] == span[2]:
                del fm[span[0]]
            save_fm(fm, body, fname); return

if __name__ == "__main__":
    op = sys.argv[1]
    if op == "get":
        cmd_get(sys.argv[2], sys.argv[3])
    elif op == "set":
        cmd_set(sys.argv[2], sys.argv[3], sys.argv[4])
    elif op == "root-get":
        cmd_root_get(sys.argv[2], sys.argv[3])
    elif op == "root-set":
        cmd_root_set(sys.argv[2], sys.argv[3], sys.argv[4])
    elif op == "root-del":
        cmd_root_del(sys.argv[2], sys.argv[3])
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

# roots map fallback: lines under a top-level `roots:` shaped  "<cwd>": <repo>
awk_root_get() { # cwd file
  awk -v key="$1" '
    NR == 1 && $0 ~ /^---[ \t]*$/ { infm = 1; next }
    infm && $0 ~ /^---[ \t]*$/ { exit }
    !infm { exit }
    /^[^ \t#]/ { inroots = ($0 ~ /^roots:[ \t]*$/); next }
    inroots && /^[ \t]+["\x27]?[^"\x27]+["\x27]?:[ \t]*[^ \t]/ {
      k = $0; sub(/^[ \t]+/, "", k); v = k
      sub(/["\x27]?:[ \t].*$/, "", k); sub(/^["\x27]/, "", k)
      sub(/^[^:]*:[ \t]*/, "", v); sub(/[ \t]+#.*$/, "", v)
      if (v ~ /^\[.*\]$/) { v = substr(v, 2, length(v) - 2); gsub(/[ \t]*,[ \t]*/, "\n", v) }
      gsub(/^["\x27]|["\x27]$/, "", v); gsub(/\n["\x27]|["\x27]\n/, "\n", v)
      if (k == key) { print v; found = 1; exit }
    }
    END { exit found ? 0 : 1 }' "$2"
}

awk_root_del() { # cwd file
  local tmp; [ -f "$2" ] || return 0
  tmp="$(mktemp)"
  awk -v key="$1" '
    NR == 1 && $0 ~ /^---[ \t]*$/ { infm = 1; print; next }
    infm && $0 ~ /^---[ \t]*$/ { infm = 0 }
    infm && /^[^ \t#]/ { inroots = ($0 ~ /^roots:[ \t]*$/) }
    infm && inroots && /^[ \t]+/ {
      k = $0; sub(/^[ \t]+/, "", k); sub(/["\x27]?:[ \t].*$/, "", k); sub(/^["\x27]/, "", k)
      if (k == key) next
    }
    { print }' "$2" > "$tmp" && mv "$tmp" "$2"
  # drop a `roots:` line left without children
  tmp="$(mktemp)"
  awk '{ lines[NR] = $0 } END {
    for (i = 1; i <= NR; i++) {
      if (lines[i] ~ /^roots:[ \t]*$/ && (i == NR || lines[i+1] !~ /^[ \t]+[^ \t]/)) continue
      print lines[i] } }' "$2" > "$tmp" && mv "$tmp" "$2"
}

awk_root_set() { # cwd repos(newline-separated) file
  local tmp val
  val="[$(printf '%s' "$2" | awk 'NR > 1 { printf ", " } { printf "%s", $0 }')]"
  set -- "$1" "$val" "$3"
  awk_root_del "$1" "$3"
  [ -f "$3" ] || printf -- '---\n---\n' > "$3"
  tmp="$(mktemp)"
  awk -v key="$1" -v val="$2" '
    NR == 1 && $0 ~ /^---[ \t]*$/ { infm = 1; print; next }
    infm && $0 ~ /^---[ \t]*$/ {
      if (!done) { if (!hasroots) print "roots:"; print "  \"" key "\": " val; done = 1 }
      infm = 0; print; next
    }
    infm && /^roots:[ \t]*$/ { hasroots = 1; print; print "  \"" key "\": " val; done = 1; next }
    { print }' "$3" > "$tmp" && mv "$tmp" "$3"
}

root_map_get() { # cwd
  [ -f "$USER_FILE" ] || return 1
  if have_python; then python3 -c "$PY_CORE" root-get "$1" "$USER_FILE"; else awk_root_get "$1" "$USER_FILE"; fi
}
root_map_set() { # cwd repo
  mkdir -p "$DATA_DIR"
  if have_python; then python3 -c "$PY_CORE" root-set "$1" "$2" "$USER_FILE"; else awk_root_set "$1" "$2" "$USER_FILE"; fi
}
root_map_del() { # cwd
  if have_python; then python3 -c "$PY_CORE" root-del "$1" "$USER_FILE"; else awk_root_del "$1" "$USER_FILE"; fi
}

# ---------------------------------------------------------------- root resolution
abs_dir() { # path -> absolute, ~ expanded, relative to CWD; exit 1 if not a directory
  local p="$1"
  case "$p" in "~") p="$HOME" ;; "~/"*) p="$HOME/${p#\~/}" ;; esac
  [ "${p#/}" = "$p" ] && p="$CWD/$p"
  [ -d "$p" ] || return 1
  (cd "$p" && pwd -P)
}

OPT_REPOS=()
ARGS=()
while [ $# -gt 0 ]; do
  case "$1" in
    --repo)   [ $# -ge 2 ] || die "--repo needs a path"; OPT_REPOS+=("$2"); shift 2 ;;
    --repo=*) OPT_REPOS+=("${1#--repo=}"); shift ;;
    *)        ARGS+=("$1"); shift ;;
  esac
done
set -- "${ARGS[@]+"${ARGS[@]}"}"

CWD="$(abs_dir "$CWD" || echo "$CWD")"
ROOTS=()
resolve_roots() {
  local r
  if [ -n "${HYPERUI_ROOT:-}" ]; then
    local parts=()
    IFS=: read -r -a parts <<<"$HYPERUI_ROOT"
    for r in "${parts[@]+"${parts[@]}"}"; do
      [ -n "$r" ] && ROOTS+=("$(abs_dir "$r" || die "HYPERUI_ROOT: not a directory: $r")")
    done
  elif [ ${#OPT_REPOS[@]} -gt 0 ]; then
    for r in "${OPT_REPOS[@]}"; do ROOTS+=("$(abs_dir "$r" || die "--repo: not a directory: $r")"); done
  else
    while IFS= read -r r; do
      [ -n "$r" ] || continue
      if abs_dir "$r" >/dev/null; then ROOTS+=("$(abs_dir "$r")")
      else echo "profile.sh: remembered root $r no longer exists; skipping it (root-clear to forget it)" >&2; fi
    done < <(root_map_get "$CWD" 2>/dev/null || true)
  fi
  [ ${#ROOTS[@]} -gt 0 ] || ROOTS=("$CWD")
}
resolve_roots
PROJECT_DIR="${ROOTS[0]}"
HYPERUI_DIR="$PROJECT_DIR/.hyperui"
PROFILE="$HYPERUI_DIR/profile.md"

cmd_root_set() { # [--replace] [--move] path...
  local replace=0 move=0 p t new=() cur=() x seen
  for p in "$@"; do
    case "$p" in --replace) replace=1 ;; --move) move=1 ;; *) t="$(abs_dir "$p")" || die "not a directory: $p"; new+=("$t") ;; esac
  done
  [ ${#new[@]} -gt 0 ] || die "usage: root-set [--replace] <path>..."
  if [ ${#new[@]} -eq 1 ] && [ "${new[0]}" = "$CWD" ]; then
    root_map_del "$CWD"; echo "$CWD"; return 0
  fi
  if [ $replace -eq 0 ]; then
    while IFS= read -r x; do [ -n "$x" ] && [ -d "$x" ] && cur+=("$x"); done < <(root_map_get "$CWD" 2>/dev/null || true)
  fi
  for t in "${new[@]}"; do
    seen=0; for x in "${cur[@]+"${cur[@]}"}"; do [ "$x" = "$t" ] && seen=1; done
    [ $seen -eq 1 ] || cur+=("$t")
  done
  root_map_set "$CWD" "$(printf '%s\n' "${cur[@]}")"
  if [ $move -eq 1 ] && [ -d "$CWD/.hyperui" ] && [ "${new[0]}" != "$CWD" ]; then
    if [ -e "${new[0]}/.hyperui" ]; then
      echo "profile.sh: ${new[0]}/.hyperui already exists; $CWD/.hyperui left in place" >&2
    else
      mv "$CWD/.hyperui" "${new[0]}/.hyperui" && echo "moved $CWD/.hyperui -> ${new[0]}/.hyperui" >&2
    fi
  fi
  printf '%s\n' "${cur[@]}"
}

cmd_root_clear() { root_map_del "$CWD"; echo "$CWD"; }

cmd_inspect() { # [root] — read-only summary so skills can infer the stack without leaving cwd
  local r="${1:-$PROJECT_DIR}" f found=()
  r="$(abs_dir "$r")" || die "not a directory: ${1:-$PROJECT_DIR}"
  echo "root: $r"
  [ -d "$r/.git" ] && echo "git: yes" || echo "git: no"
  echo "files: $(ls -1A "$r" 2>/dev/null | grep -v '^\.DS_Store$' | head -40 | tr '\n' ' ')"
  for f in package.json pnpm-lock.yaml yarn.lock bun.lock bun.lockb package-lock.json next.config.js next.config.mjs next.config.ts \
           angular.json vite.config.ts vite.config.js astro.config.mjs nuxt.config.ts svelte.config.js app.json app.config.ts \
           tailwind.config.js tailwind.config.ts postcss.config.js tsconfig.json pubspec.yaml Package.swift Cargo.toml go.mod \
           pyproject.toml requirements.txt pom.xml build.gradle build.gradle.kts Gemfile composer.json tauri.conf.json \
           Dockerfile docker-compose.yml compose.yaml Makefile .github/workflows .gitlab-ci.yml terraform main.tf infra; do
    [ -e "$r/$f" ] && found+=("$f")
  done
  ls -d "$r"/*.xcodeproj "$r"/*.xcworkspace >/dev/null 2>&1 && found+=("xcodeproj")
  echo "markers: ${found[*]:-none}"
  if [ -f "$r/package.json" ]; then
    if have_python; then
      python3 - "$r/package.json" <<'PYI'
import json, sys
try:
    d = json.load(open(sys.argv[1], encoding="utf-8"))
except Exception as e:
    print("package.json: unreadable (%s)" % e); sys.exit(0)
print("package.json name:", d.get("name", ""))
for k in ("dependencies", "devDependencies"):
    v = d.get(k) or {}
    if v: print("%s: %s" % (k, " ".join("%s@%s" % (a, b) for a, b in sorted(v.items()))))
sc = d.get("scripts") or {}
if sc: print("scripts:", " ".join(sorted(sc)))
PYI
    else
      echo "package.json: $(grep -E '^\s*"[^"]+"\s*:\s*"[~^]?[0-9]' "$r/package.json" | tr -d ' ",' | tr '\n' ' ')"
    fi
  fi
  [ -f "$r/pubspec.yaml" ] && echo "pubspec: $(grep -E '^\s{2}[a-z_]+:' "$r/pubspec.yaml" | tr -d ' ' | tr '\n' ' ' | cut -c1-300)"
  [ -f "$r/pyproject.toml" ] && echo "pyproject: $(grep -E '^(name|requires-python|dependencies)' "$r/pyproject.toml" | tr '\n' ' ' | cut -c1-300)"
  [ -f "$r/go.mod" ] && echo "go.mod: $(head -1 "$r/go.mod")"
  [ -f "$r/Cargo.toml" ] && echo "Cargo.toml: $(grep -E '^(name|edition)' "$r/Cargo.toml" | tr '\n' ' ')"
  return 0
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
  root)     echo "$PROJECT_DIR" ;;
  roots)    printf '%s\n' "${ROOTS[@]}" ;;
  root-set) cmd_root_set "$@" ;;
  root-clear) cmd_root_clear ;;
  inspect)  cmd_inspect "$@" ;;
  -h|--help|help|"") usage ;;
  *)        die "unknown command: $cmd (try --help)" ;;
esac
