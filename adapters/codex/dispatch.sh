#!/usr/bin/env bash
# Translate documented Codex lifecycle events to the existing Claude hooks.
# Hooks are best-effort guardrails, not a sandbox. See README.md.
set -u
ROOT=$(cd "$(dirname "${BASH_SOURCE[0]}")/../.." && pwd -P)
command -v jq >/dev/null 2>&1 || exit 0
input=$(cat)
event=$(printf '%s' "$input" | jq -r '.hook_event_name // empty' 2>/dev/null) || exit 0
project=$(printf '%s' "$input" | jq -r '.cwd // empty' 2>/dev/null) || exit 0
[ -n "$project" ] && [ -d "$project" ] || exit 0
export CLAUDE_PROJECT_DIR="$project"
export HARNESS_HOME="${HARNESS_HOME:-${XDG_STATE_HOME:-$HOME/.local/state}/agent-foundry}"

case $event in
  SessionStart|Stop)
    # The gate returns either an empty success or a JSON continuation request.
    result=$(printf '%s' "$input" | "$ROOT/hooks/project-gate.sh") || exit 0
    if [ -n "$result" ]; then printf '%s\n' "$result"; else printf '{}\n'; fi
    ;;
  PreToolUse)
    tool=$(printf '%s' "$input" | jq -r '.tool_name // empty' 2>/dev/null)
    [ "$tool" = Bash ] || exit 0
    tmp=$(mktemp -d) || exit 0
    trap 'rm -rf "$tmp"' EXIT
    for guard in guard-bash guard-secrets; do
      code=0
      printf '%s' "$input" | "$ROOT/hooks/$guard.sh" >"$tmp/out" 2>"$tmp/err" || code=$?
      if [ "$code" -eq 2 ]; then
        cat "$tmp/err" >&2
        exit 2
      fi
      if [ "$code" -ne 0 ]; then
        # Guard errors are not affirmative authorization, but the runtime may
        # continue on hook errors. Surface that limitation instead of hiding it.
        printf '%s\n' "Agent Foundry: $guard failed (exit $code); guard coverage is unavailable." >&2
        exit "$code"
      fi
      if jq -e '.hookSpecificOutput.permissionDecision == "ask"' "$tmp/out" >/dev/null 2>&1; then
        reason=$(jq -r '.hookSpecificOutput.permissionDecisionReason // "Action requires approval."' "$tmp/out")
        jq -n --arg reason "$reason Codex hooks cannot request approval; run this action explicitly outside the agent after review." \
          '{hookSpecificOutput:{hookEventName:"PreToolUse",permissionDecision:"deny",permissionDecisionReason:$reason}}'
        exit 0
      fi
    done
    ;;
esac
