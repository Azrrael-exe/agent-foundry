#!/usr/bin/env bash
# SessionStart + Stop: run the project's check command on changes made during
# this session and refuse to finish while it fails.
# Convention, first match wins: executable .harness/check.sh, then
# .claude/check.sh, a `check` recipe in a justfile, or a Makefile target.
# Runs only in trusted git projects. Disable per project with HARNESS_GATE=off.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
[ "${HARNESS_GATE:-}" = off ] && exit 0
cd "$PROJECT" 2>/dev/null || exit 0
is_trusted "$PWD" || exit 0 # the check command is repo code
# ponytail: git-only; without git there is no cheap way to know what changed.
git rev-parse --is-inside-work-tree >/dev/null 2>&1 || exit 0

# Locate the shared implementation even when the legacy installer has linked
# this individual hook into ~/.claude/hooks.
gate_source=${BASH_SOURCE[0]}
if [ -L "$gate_source" ]; then
  gate_link=$(readlink "$gate_source")
  case $gate_link in
    /*) gate_source=$gate_link ;;
    *) gate_source=${gate_source%/*}/$gate_link ;;
  esac
  unset gate_link
fi
# shellcheck source=../core/check.sh
. "${gate_source%/*}/../core/check.sh" || exit 0
# shellcheck source=../core/gate.sh
. "${gate_source%/*}/../core/gate.sh" || exit 0
unset gate_source
foundry_find_check || exit 0
cmd=("${FOUNDRY_CHECK[@]}")

sid=$(field .session_id)
sid=${sid//[^A-Za-z0-9_-]/}
[ -n "$sid" ] || sid=nosession
state="$HARNESS_HOME/gate/$(printf '%s' "$PWD" | shasum | cut -c1-16).$sid"
mkdir -p "${state%/*}"

if [ "$EVENT" = SessionStart ]; then
  # Keep the first baseline (resume/compact must not move it), but refresh its
  # mtime so the 14-day cleanup never drops a live session's baseline.
  if [ -f "$state.base" ]; then touch "$state.base"; else foundry_gate_set_base "$state"; fi
  find "${state%/*}" -type f -mtime +14 -delete 2>/dev/null
  exit 0
fi
[ "$EVENT" = Stop ] || exit 0
foundry_gate_needs_check "$state" || exit 0

out=$("${cmd[@]}" 2>&1)
code=$?
# Stamp the tree as it is after the check: the check may rewrite files.
if [ "$code" = 0 ]; then
  foundry_gate_record "$state" pass
  exit 0
fi
foundry_gate_record "$state" fail
log_event project-gate check-failed block "${cmd[*]}"
reason=$(printf "project-gate [check-failed]: '%s' failed (exit %s). Fix the failures before finishing, or explain to the user why they cannot be fixed now. (The user can disable this gate per project with HARNESS_GATE=off.)\n%s" \
  "${cmd[*]}" "$code" "$(printf '%s\n' "$out" | tail -n 50)")
jq -n --arg r "$reason" '{decision: "block", reason: $r}'
exit 0
