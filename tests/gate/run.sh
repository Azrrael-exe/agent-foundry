#!/usr/bin/env bash
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# shellcheck source=../../core/gate.sh
. "$ROOT/core/gate.sh"
mkdir -p "$TMP/project" "$TMP/state"
cd "$TMP/project"
git init -q -b main
git -c user.name=test -c user.email=test@example.invalid commit -q --allow-empty -m baseline
state="$TMP/state/session"
expect() { local name=$1; shift; if "$@"; then printf 'OK    %s\n' "$name"; else printf 'FAIL  %s\n' "$name"; exit 1; fi; }
no_check() { if foundry_gate_needs_check "$state"; then return 1; else return 0; fi; }
expect 'clean tree needs no check' no_check
printf 'first\n' >work.txt
expect 'missing baseline records existing work' no_check
expect 'unchanged baseline needs no check' no_check
printf 'second\n' >work.txt
expect 'changed untracked content requires check' foundry_gate_needs_check "$state"
foundry_gate_record "$state" fail
expect 'failed tree is not checked twice' no_check
printf 'third\n' >work.txt
expect 'changed tree is checked again' foundry_gate_needs_check "$state"
foundry_gate_record "$state" pass
expect 'passing tree is cached' no_check
git add work.txt
expect 'staging changes the fingerprint' foundry_gate_needs_check "$state"
