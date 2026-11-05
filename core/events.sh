# shellcheck shell=bash
# Record one harness event. Callers must provide a non-sensitive summary;
# this function does not inspect or redact secrets in event fields.
# Arguments: state directory, project, session, hook, rule, decision, summary.
# Logging failures do not change the caller's decision.
foundry_log_event() {
  local state=$1 project=$2 session=$3 hook=$4 rule=$5 decision=$6 summary=${7:--}
  case $project in "$HOME" | "$HOME"/*) project="~${project#"$HOME"}" ;; esac
  mkdir -p "$state" 2>/dev/null &&
    jq -nc --arg h "$hook" --arg r "$rule" --arg d "$decision" --arg s "$summary" \
      --arg p "$project" --arg sid "$session" \
      '{ts: (now | todate), hook: $h, rule: $r, decision: $d, project: $p, session: $sid, summary: $s}' \
      >>"$state/events.jsonl" 2>/dev/null
  return 0
}
