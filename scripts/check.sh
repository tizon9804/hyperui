#!/usr/bin/env bash
# hyperui quality gate. Run from anywhere: scripts/check.sh
#
# Checks, in order:
#   (a) claude plugin validate .        — manifests + skills            (hard fail)
#   (b) bash -n scripts/*.sh            — every script parses           (hard fail)
#   (c) frontmatter lint                — every SKILL.md (skills/*/ and root) has
#                                         name: and description:        (hard fail)
#                                         every skills/*/SKILL.md except setup/doctor has
#                                         user-invocable: false         (gated, see below)
#   (d) sources lint                    — every skills/*/SKILL.md except setup/doctor has a
#                                         "## Sources" heading          (gated, see below)
#   (d2) allowed-tools lint             — every skills/*/SKILL.md except setup/doctor declares
#                                         allowed-tools with Read(//${CLAUDE_PLUGIN_ROOT}/**)
#                                         (the only form that pre-approves reference reads
#                                         AND stays scoped to the plugin; bare Read leaks,
#                                         single-slash form never matches)      (gated)
#   (d3) preamble lint                  — every skills/*/SKILL.md except setup/doctor contains
#                                         the exact phrase "invoke the `hyperui` skill first"
#                                         (profile-missing fallback)    (gated)
#   (e) company-agnostic grep           — no employer/team-specific strings anywhere in the
#                                         repo (excluding .git, node_modules and this file,
#                                         which necessarily contains the pattern)  (hard fail)
#
# Gate toggle (.hyperui-gate at the repo root):
#   The file holds a single word on its first non-comment line:
#     lenient  — (c)'s user-invocable rule and (d)/(d2)/(d3) print "!" warnings, exit code unaffected.
#                Used during wave 1 so specialists can be migrated incrementally.
#     strict   — those warnings become failures. Flip to strict once every specialist is done.
#   Lines starting with "#" are comments. A missing file means lenient.
#
# Exit code: 0 when every hard check passes, 1 otherwise.
set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$ROOT"

FAIL=0
WARN=0
ok()   { printf '[check] \xe2\x9c\x93 %s\n' "$*"; }
bad()  { printf '[check] \xe2\x9c\x97 %s\n' "$*"; FAIL=1; }
warn() { printf '[check] ! %s\n' "$*"; WARN=$((WARN + 1)); }

GATE="lenient"
if [[ -f .hyperui-gate ]]; then
  GATE="$(grep -vE '^[[:space:]]*(#|$)' .hyperui-gate | head -n1 | tr -d '[:space:]' || true)"
  [[ -z "$GATE" ]] && GATE="lenient"
fi
case "$GATE" in
  lenient|strict) ;;
  *) bad ".hyperui-gate: unknown value '$GATE' (expected lenient|strict)"; GATE="strict" ;;
esac
# gated: report a gated finding as a warning (lenient) or a failure (strict)
gated() { if [[ "$GATE" == "strict" ]]; then bad "$*"; else warn "$* (gate: lenient)"; fi; }

# (a) plugin validate
if command -v claude >/dev/null 2>&1; then
  if out="$(claude plugin validate . 2>&1)"; then
    ok "claude plugin validate ."
  else
    bad "claude plugin validate . failed:"
    printf '%s\n' "$out" | sed 's/^/        /'
  fi
else
  bad "claude CLI not found; cannot run 'claude plugin validate .'"
fi

# (b) bash -n
shopt -s nullglob
scripts=(scripts/*.sh)
bn_fail=0
for f in "${scripts[@]}"; do
  if ! err="$(bash -n "$f" 2>&1)"; then
    bad "bash -n $f: $err"; bn_fail=1
  fi
done
[[ $bn_fail -eq 0 ]] && ok "bash -n on ${#scripts[@]} script(s)"

# frontmatter helper: prints the YAML frontmatter block (between the first two --- lines)
frontmatter() {
  awk 'NR==1 && $0!="---" {exit} NR==1 {next} $0=="---" {exit} {print}' "$1"
}

# (c) frontmatter lint + (d) sources lint
skill_files=(skills/*/SKILL.md)
[[ -f SKILL.md ]] && skill_files+=(SKILL.md)
fm_fail=0; gated_count=0
for f in "${skill_files[@]}"; do
  fm="$(frontmatter "$f")"
  if [[ -z "$fm" ]]; then bad "$f: missing YAML frontmatter"; fm_fail=1; continue; fi
  grep -qE '^name:[[:space:]]*[^[:space:]]' <<<"$fm" || { bad "$f: frontmatter lacks name:"; fm_fail=1; }
  grep -qE '^description:[[:space:]]*[^[:space:]]' <<<"$fm" || { bad "$f: frontmatter lacks description:"; fm_fail=1; }

  [[ "$f" == SKILL.md ]] && continue
  skill="$(basename "$(dirname "$f")")"
  [[ "$skill" == setup || "$skill" == doctor ]] && continue
  if ! grep -qE '^user-invocable:[[:space:]]*false[[:space:]]*$' <<<"$fm"; then
    gated "$f: specialist lacks 'user-invocable: false'"; gated_count=$((gated_count + 1))
  fi
  if ! grep -qE '^##[[:space:]]+Sources[[:space:]]*$' "$f"; then
    gated "$f: specialist lacks a '## Sources' heading"; gated_count=$((gated_count + 1))
  fi
  if ! grep -qF 'Read(//${CLAUDE_PLUGIN_ROOT}/**)' <<<"$fm"; then
    gated "$f: specialist lacks allowed-tools 'Read(//\${CLAUDE_PLUGIN_ROOT}/**)' (reference reads outside the project need it)"; gated_count=$((gated_count + 1))
  fi
  if ! grep -qF 'invoke the `hyperui` skill first' "$f"; then
    gated "$f: specialist lacks the preamble phrase 'invoke the \`hyperui\` skill first'"; gated_count=$((gated_count + 1))
  fi
done
[[ $fm_fail -eq 0 ]] && ok "frontmatter name/description on ${#skill_files[@]} SKILL.md file(s)"
[[ $gated_count -eq 0 ]] && ok "specialists: user-invocable: false + ## Sources + allowed-tools + preamble phrase (gate: $GATE)"

# (e) company-agnostic grep
if hits="$(grep -rniE '\bolo\b|ubits|ololabs|engage-specs|OLO-[0-9]' \
      --exclude-dir=.git --exclude-dir=node_modules --exclude=check.sh . 2>/dev/null)"; then
  bad "company-agnostic grep found hits:"
  printf '%s\n' "$hits" | sed 's/^/        /'
else
  ok "company-agnostic grep: clean"
fi

if [[ $FAIL -ne 0 ]]; then
  printf '[check] \xe2\x9c\x97 FAILED (%d warning(s))\n' "$WARN"; exit 1
fi
printf '[check] \xe2\x9c\x93 PASSED (%d warning(s), gate: %s)\n' "$WARN" "$GATE"
exit 0
