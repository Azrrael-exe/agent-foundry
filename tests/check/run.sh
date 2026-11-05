#!/usr/bin/env bash
# shellcheck disable=SC2016 # The quoted script is a literal test fixture.
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# shellcheck source=../../core/check.sh
. "$ROOT/core/check.sh"
mkdir -p "$TMP/project with spaces/.claude" "$TMP/bin"
cd "$TMP/project with spaces"
expect() {
  local expected=$1
  shift
  if "$@"; then printf 'OK    %s\n' "$expected"; else printf 'FAIL  %s\n' "$expected"; exit 1; fi
}
none() { if foundry_find_check; then return 1; else [ "${#FOUNDRY_CHECK[@]}" -eq 0 ]; fi; }
is_command() { foundry_find_check && [ "${FOUNDRY_CHECK[*]}" = "$1" ]; }
expect 'no check' none
printf 'check := value\n' >Makefile
expect 'make variable is not a target' none
printf 'check:\n\t@true\n' >Makefile
expect 'make check' is_command 'make check'
printf '#!/bin/sh\n[ "$1" = --summary ] && echo "build check test"\n' >"$TMP/bin/just"
chmod +x "$TMP/bin/just"
export PATH="$TMP/bin:$PATH"
printf 'check:\n' >justfile
expect 'just precedes make' is_command 'just check'
printf '#!/bin/sh\nexit 0\n' >.claude/check.sh
expect 'non-executable script is ignored' is_command 'just check'
chmod +x .claude/check.sh
expect 'script precedes just and make' is_command '.claude/check.sh'
mkdir -p .harness
printf '#!/bin/sh\nexit 0\n' >.harness/check.sh
chmod +x .harness/check.sh
expect 'portable script precedes legacy Claude script' is_command '.harness/check.sh'
rm .harness/check.sh

# Exercise the Claude gate through the legacy installer's individual symlinks.
mkdir -p "$TMP/linked-hooks" "$TMP/state"
for hook in project-gate.sh lib.sh trust.sh; do ln -s "$ROOT/hooks/$hook" "$TMP/linked-hooks/$hook"; done
printf '%s\n' "$PWD" >"$TMP/state/trusted-projects"
git init -q -b main
git -c user.name=test -c user.email=test@example.invalid commit -q --allow-empty -m baseline
printf '#!/bin/sh\nexit 1\n' >.claude/check.sh
git add .claude/check.sh
git -c user.name=test -c user.email=test@example.invalid commit -qm check
export HARNESS_HOME="$TMP/state" CLAUDE_PROJECT_DIR="$PWD"
printf '{"hook_event_name":"SessionStart","session_id":"test"}' | "$TMP/linked-hooks/project-gate.sh"
printf 'changed\n' >changed.txt
result=$(printf '{"hook_event_name":"Stop","session_id":"test"}' | "$TMP/linked-hooks/project-gate.sh")
expect 'linked Claude gate executes the selected failing check' jq -e '.decision == "block"' <<<"$result" >/dev/null
printf 'OK    linked Claude gate executes the selected failing check\n'
