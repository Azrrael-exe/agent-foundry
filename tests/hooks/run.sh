#!/usr/bin/env bash
# Run hook fixtures and print a results table. Exit 1 on any failure.
#
# Fixture: cases/<hook>/<expect>-<rule>-<n>.json, the hook's stdin JSON.
#   expect: pass  -> exit 0, no ask decision
#           block -> exit 2, stderr mentions [<rule>]
#           ask   -> exit 0, permissionDecision "ask"
#           block also matches a Stop {"decision":"block"} on stdout
# Every block/ask must append exactly one events.jsonl line with that hook
# and rule; a pass must append none. Logged events are finally scanned for
# fake credentials and temp paths (summaries must carry no sensitive data).
# Optional <same-name>.vars: VAR=value lines exported for that case only.
# Optional <same-name>.setup: bash run inside a fresh copy of the project
# before the case (create check.sh, Makefile, tool shims, prior hook runs via
# $HOOKS_DIR, ...). $HARNESS_HOME is fresh per case and trusts $TMP.
# Placeholders: @@PROJECT@@ (fake git repo on main), @@HOME@@, and fake
# credentials (@@AWS_KEY@@ ...) assembled here so no versioned file
# contains a key-like string.
set -u
HERE=$(cd "$(dirname "$0")" && pwd)
ROOT=$(cd "$HERE/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT

BASE="$TMP/base" PROJECT="$TMP/project"
export HARNESS_HOME="$TMP/harness" HOOKS_DIR="$ROOT/hooks"
mkdir -p "$BASE/build" "$BASE/sub"
git -C "$BASE" init -q -b main
git -C "$BASE" -c user.name=t -c user.email=t@t commit -q --allow-empty -m init
git -C "$BASE" branch feature

AWS_KEY="AKIA""IOSFODNN7EXAMPLE"
GH_TOKEN="ghp_""$(printf 'a%.0s' $(seq 36))"
ANT_KEY="sk-ant-""api03-$(printf 'x%.0s' $(seq 24))"
PEM="-----BEGIN RSA ""PRIVATE KEY-----"

ms() { perl -MTime::HiRes=time -e 'printf "%d", time*1000'; }

fail=0 total=0 max_ms=0
printf '%-15s %-36s %-6s %-6s %5s  %s\n' HOOK CASE EXPECT GOT MS RESULT
for f in "$HERE"/cases/*/*.json; do
  hook=$(basename "$(dirname "$f")")
  name=$(basename "$f" .json)
  expect=${name%%-*}
  rule=${name#*-}
  rule=${rule%-*}
  input=$(sed -e "s|@@PROJECT@@|$PROJECT|g" -e "s|@@HOME@@|$HOME|g" \
    -e "s|@@AWS_KEY@@|$AWS_KEY|g" -e "s|@@GH_TOKEN@@|$GH_TOKEN|g" \
    -e "s|@@ANT_KEY@@|$ANT_KEY|g" -e "s|@@PEM@@|$PEM|g" "$f")
  rm -rf "$PROJECT" "$HARNESS_HOME" && cp -R "$BASE" "$PROJECT"
  mkdir -p "$HARNESS_HOME" && echo "$TMP" >"$HARNESS_HOME/trusted-projects"
  if [ -f "${f%.json}.setup" ]; then (cd "$PROJECT" && bash "${f%.json}.setup"); fi
  vars="$TMP/vars"
  : >"$vars"
  if [ -f "${f%.json}.vars" ]; then sed "s|@@PROJECT@@|$PROJECT|g" "${f%.json}.vars" >"$vars"; fi
  ev="$HARNESS_HOME/events.jsonl"
  n0=$(cat "$ev" 2>/dev/null | wc -l)
  t0=$(ms)
  (
    cd "$PROJECT" || exit 99
    # shellcheck disable=SC1090 # per-case vars file
    set -a && . "$vars" && set +a
    printf '%s' "$input" | CLAUDE_PROJECT_DIR=$PROJECT "$ROOT/hooks/$hook.sh" \
      >"$TMP/out" 2>"$TMP/err"
  )
  code=$?
  dt=$(($(ms) - t0))
  [ "$dt" -gt "$max_ms" ] && max_ms=$dt
  if [ "$code" = 2 ] || grep -q '"decision": *"block"' "$TMP/out"; then
    got=block
    [ "$expect" = block ] && ! grep -q "\[$rule\]" "$TMP/err" "$TMP/out" && got=block:wrong-rule
  elif [ "$code" = 0 ] && grep -q '"ask"' "$TMP/out"; then
    got=ask
  elif [ "$code" = 0 ]; then
    got=pass
  else
    got=exit$code
  fi
  # Event log contract.
  new=$(tail -n +$((n0 + 1)) "$ev" 2>/dev/null)
  cat "$ev" >>"$TMP/all-events" 2>/dev/null
  n_new=$(printf '%s' "$new" | grep -c . || true)
  case $got in
  block | ask)
    if [ "$n_new" != 1 ] || [ "$(printf '%s' "$new" | jq -r '"\(.hook) \(.rule) \(.decision)"')" != "$hook $rule $got" ]; then
      got="$got:log-mismatch"
    fi
    ;;
  pass) [ "$n_new" = 0 ] || got="pass:unexpected-log" ;;
  esac
  total=$((total + 1))
  if [ "$got" = "$expect" ]; then res=OK; else res=FAIL fail=$((fail + 1)); fi
  printf '%-15s %-36s %-6s %-6s %5s  %s\n' "$hook" "$name" "$expect" "$got" "$dt" "$res"
  [ "$res" = FAIL ] && sed 's/^/    stderr: /' "$TMP/err"
done

if [ -s "$TMP/all-events" ]; then
  if grep -qF -e "$AWS_KEY" -e "$GH_TOKEN" -e "$ANT_KEY" -e "PRIVATE KEY" "$TMP/all-events" ||
    jq -r .summary "$TMP/all-events" | grep -qF "$TMP"; then
    echo "FAIL: events.jsonl contains a credential or a full path in summary"
    fail=$((fail + 1))
  else
    echo "event log: $(wc -l <"$TMP/all-events" | tr -d ' ') lines logged, no sensitive data in them"
  fi
fi

echo
echo "$((total - fail))/$total passed, slowest case ${max_ms} ms (includes timer overhead)"

if command -v shellcheck >/dev/null 2>&1; then
  if shellcheck -x -P SCRIPTDIR "$ROOT"/hooks/*.sh "$ROOT/install.sh" "$ROOT/statusline.sh" "$ROOT"/bin/* "$HERE/run.sh"; then
    echo "shellcheck: clean"
  else
    fail=$((fail + 1))
  fi
else
  echo "shellcheck: not installed, skipped"
fi
[ "$fail" = 0 ]
