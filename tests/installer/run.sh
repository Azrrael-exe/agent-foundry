#!/usr/bin/env bash
set -euo pipefail
ROOT=$(cd "$(dirname "$0")/../.." && pwd -P)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
export HOME="$TMP/home"
mkdir -p "$HOME"
foundry="$ROOT/bin/foundry"

expect() { local name=$1; shift; if "$@"; then printf 'OK    %s\n' "$name"; else printf 'FAIL  %s\n' "$name"; exit 1; fi; }
link_points_to() { [ -L "$1" ] && [ "$(readlink "$1")" = "$2" ]; }
missing() { [ ! -e "$1" ] && [ ! -L "$1" ]; }
rejected() { if "$@" >/dev/null 2>&1; then return 1; else return 0; fi; }
contains_doctor_status() { [[ $1 == *codex* && $1 == *'not checked'* ]]; }

"$foundry" skills install claude >/dev/null
expect 'Claude skill link is created' link_points_to "$HOME/.claude/skills/handoff" "$ROOT/skills/handoff"
"$foundry" skills install claude >/dev/null
expect 'Claude installation is idempotent' link_points_to "$HOME/.claude/skills/handoff" "$ROOT/skills/handoff"
"$foundry" skills install codex >/dev/null
expect 'Codex skill link is created' link_points_to "$HOME/.agents/skills/handoff" "$ROOT/skills/handoff"
mkdir -p "$HOME/.gemini/config/skills/harness-retro"
expect 'conflicting skill blocks installation' rejected "$foundry" skills install antigravity
expect 'conflict preflight leaves earlier names untouched' missing "$HOME/.gemini/config/skills/git-hygiene"
rmdir "$HOME/.gemini/config/skills/harness-retro"
"$foundry" skills install antigravity >/dev/null
expect 'Antigravity skill link is created' link_points_to "$HOME/.gemini/config/skills/handoff" "$ROOT/skills/handoff"
rm "$HOME/.claude/skills/handoff"
mkdir "$HOME/.claude/skills/handoff"
"$foundry" skills uninstall claude >/dev/null
expect 'uninstall preserves foreign directory' test -d "$HOME/.claude/skills/handoff"
expect 'uninstall removes owned links' missing "$HOME/.claude/skills/git-hygiene"
expect 'unknown platform is rejected' rejected "$foundry" skills install unknown
output=$("$foundry" doctor)
expect 'doctor reports links and limits' contains_doctor_status "$output"
