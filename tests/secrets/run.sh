#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2088 # Literal jq programs and tilde path are test inputs.
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# shellcheck source=../../core/secrets.sh
. "$ROOT/core/secrets.sh"
export HOME="$TMP/home"
mkdir -p "$HOME/project" "$TMP/linked-hooks"
expect() { local name=$1; shift; if "$@"; then printf 'OK    %s\n' "$name"; else printf 'FAIL  %s\n' "$name"; exit 1; fi; }
not_secret_path() { if foundry_secret_path "$1"; then return 1; else return 0; fi; }
not_secret_content() { if foundry_secret_content "$1"; then return 1; else return 0; fi; }
expect 'env file is sensitive' foundry_secret_path "$HOME/project/.env"
expect 'sample env is allowed' not_secret_path "$HOME/project/.env.example"
expect 'public key is allowed' not_secret_path "$HOME/.ssh/id_rsa.pub"
expect 'tilde secret path is detected' foundry_secret_path '~/.ssh/id_ed25519'
expect 'sibling directory is not treated as ssh' not_secret_path "$HOME/.ssh-other/config"
fake_key="AKIA""IOSFODNN7EXAMPLE"
expect 'key-like content is detected' foundry_secret_content "token=$fake_key"
expect 'token embedded in a longer identifier is ignored' not_secret_content "prefix${fake_key}"
expect 'ordinary content is allowed' not_secret_content 'ordinary example'

for hook in guard-secrets.sh lib.sh trust.sh; do ln -s "$ROOT/hooks/$hook" "$TMP/linked-hooks/$hook"; done
input=$(jq -nc --arg cwd "$HOME/project" '{hook_event_name:"PreToolUse",tool_name:"Read",session_id:"test",cwd:$cwd,tool_input:{file_path:".env"}}')
set +e
printf '%s' "$input" | HARNESS_HOME="$TMP/state" CLAUDE_PROJECT_DIR="$HOME/project" "$TMP/linked-hooks/guard-secrets.sh" >"$TMP/out" 2>"$TMP/err"
code=$?
set -e
expect 'linked Claude hook blocks secret paths' test "$code" -eq 2
expect 'linked Claude hook records correct rule' jq -e '.hook == "guard-secrets" and .rule == "secret-path" and .decision == "block"' "$TMP/state/events.jsonl" >/dev/null
printf 'OK    linked Claude hook records correct rule\n'

mkdir -p "$TMP/missing-core/hooks"
cp "$ROOT/hooks/guard-secrets.sh" "$TMP/missing-core/hooks/"
printf 'TOOL=Read\n' >"$TMP/missing-core/hooks/lib.sh"
set +e
"$TMP/missing-core/hooks/guard-secrets.sh" >"$TMP/out" 2>"$TMP/err"
code=$?
set -e
expect 'missing shared rules fail closed' test "$code" -eq 2
expect 'missing shared rules are reported' grep -q 'guard-secrets: missing shared rules' "$TMP/err"
