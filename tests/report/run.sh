#!/usr/bin/env bash
# shellcheck disable=SC2088 # "~/..." is the literal project form stored in events
# Test harness-report against a generated events.jsonl. Exit 1 on failure.
set -u
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
export HARNESS_HOME=$TMP

ev() { # days-ago hook rule decision project session
  jq -nc --argjson d "$1" --arg h "$2" --arg r "$3" --arg x "$4" --arg p "$5" --arg s "$6" \
    '{ts: (now - $d * 86400 | todate), hook: $h, rule: $r, decision: $x, project: $p, session: $s, summary: "-"}'
}
{
  ev 1 guard-bash rm-outside-project block "~/Dev/facturas" s1
  ev 1 guard-bash rm-outside-project block "~/Dev/facturas" s1
  ev 2 guard-bash reset-hard ask "~/Dev/facturas" s2
  ev 3 guard-secrets secret-path block "~/Dev/web" s3
  ev 20 guard-bash chmod-777-recursive block "~/Dev/facturas" s4 # outside 7 days
  echo 'not json'
} >"$HARNESS_HOME/events.jsonl"

fail=0
expect() { # description, command output, fixed string that must appear
  if printf '%s\n' "$2" | grep -qF -- "$3"; then echo "OK    $1"; else
    echo "FAIL  $1: expected '$3'"
    fail=$((fail + 1))
  fi
}
reject() { # description, output, string that must NOT appear
  if printf '%s\n' "$2" | grep -qF -- "$3"; then
    echo "FAIL  $1: unexpected '$3'"
    fail=$((fail + 1))
  else echo "OK    $1"; fi
}

out=$("$ROOT/bin/harness-report" 7)
expect "7d total and decisions" "$out" "Total: 4 (3 block, 1 ask) in 3 sessions (1.3 per session)"
expect "7d by hook" "$out" "    3  guard-bash"
expect "7d by rule" "$out" "    2  guard-bash/rm-outside-project"
expect "7d by project" "$out" "    1  ~/Dev/web"
reject "7d excludes old event" "$out" "chmod-777-recursive"

out=$("$ROOT/bin/harness-report" 30 -p facturas)
expect "30d project filter" "$out" "Total: 4 (3 block, 1 ask)"
reject "30d filter drops other project" "$out" "~/Dev/web"
expect "30d includes old event" "$out" "    1  guard-bash/chmod-777-recursive"

out=$("$ROOT/bin/harness-report" 7 -p nothing-matches)
expect "empty period" "$out" "No events in this period."

out=$(HARNESS_HOME=$TMP/none "$ROOT/bin/harness-report")
expect "missing log" "$out" "No harness events recorded yet."

"$ROOT/bin/harness-report" abc >/dev/null 2>&1
expect "rejects bad days" "exit=$?" "exit=1"

[ "$fail" = 0 ]
