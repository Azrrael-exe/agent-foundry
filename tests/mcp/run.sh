#!/usr/bin/env bash
# Test bin/github-mcp-headers token selection with fake security/gh. Exit 1 on failure.
set -u
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
JQ=$(command -v jq)

# shim <dir> <name> <token or empty>: a command that prints the token, or fails.
shim() {
  mkdir -p "$1"
  if [ -n "$3" ]; then printf '#!/bin/sh\necho %s\n' "$3" >"$1/$2"; else printf '#!/bin/sh\nexit 1\n' >"$1/$2"; fi
  chmod +x "$1/$2"
}
run() { # <security token> <gh token> -> sets out, code
  local d="$TMP/$RANDOM"
  shim "$d" security "$1"
  shim "$d" gh "$2"
  ln -s "$JQ" "$d/jq"
  out=$(PATH="$d:/usr/bin:/bin" "$ROOT/bin/github-mcp-headers" 2>/dev/null)
  code=$?
}

fail=0
check() { # description, test command...
  local d=$1
  shift
  if "$@"; then echo "OK    $d"; else
    echo "FAIL  $d"
    fail=$((fail + 1))
  fi
}

run keychain-token gh-token
check "prefers the Keychain token" [ "$(printf '%s' "$out" | jq -r .Authorization)" = "Bearer keychain-token" ]
check "outputs only the Authorization header" [ "$(printf '%s' "$out" | jq -r 'keys | join(",")')" = "Authorization" ]

run "" gh-token
check "falls back to gh auth token" [ "$(printf '%s' "$out" | jq -r .Authorization)" = "Bearer gh-token" ]

run "" ""
check "no token: exit 1" [ "$code" = 1 ]
check "no token: empty stdout" [ -z "$out" ]

[ "$fail" = 0 ]
