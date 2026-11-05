# shellcheck shell=bash
# Shared helpers for harness hooks. Sourced, never executed.
# Reads the hook's stdin JSON once and exits 0 (fail open) when the hook
# cannot or should not run.

[ "${HARNESS_OFF:-}" = 1 ] && exit 0
command -v jq >/dev/null 2>&1 || exit 0

INPUT=$(cat)
field() { printf '%s' "$INPUT" | jq -r "$1 // empty" 2>/dev/null; }

TOOL=$(field .tool_name)
EVENT=$(field .hook_event_name)
[ -n "$TOOL$EVENT" ] || exit 0 # empty or invalid stdin
CWD=$(field .cwd)
CWD=${CWD:-$PWD}
# shellcheck disable=SC2034 # used by the sourcing hooks
PROJECT=${CLAUDE_PROJECT_DIR:-$CWD}
# Harness state (gate stamps, event log, trust list). Outside the dotfiles repo.
# shellcheck source=trust.sh
. "${BASH_SOURCE[0]%/*}/trust.sh"

# The existing installer symlinks individual hooks, including this library.
# Resolve the link before loading the provider-neutral event writer.
_foundry_lib_source=${BASH_SOURCE[0]}
if [ -L "$_foundry_lib_source" ]; then
  _foundry_lib_link=$(readlink "$_foundry_lib_source")
  case $_foundry_lib_link in
    /*) _foundry_lib_source=$_foundry_lib_link ;;
    *) _foundry_lib_source=${_foundry_lib_source%/*}/$_foundry_lib_link ;;
  esac
  unset _foundry_lib_link
fi
# Logging remains fail-open even if the shared implementation is unavailable.
# shellcheck source=../core/events.sh
. "${_foundry_lib_source%/*}/../core/events.sh" 2>/dev/null || true
unset _foundry_lib_source

# log_event <hook> <rule> <decision> <summary>: one line in events.jsonl.
# summary must never carry command text or file content (it may hold secrets).
# Fails open: a logging error never changes the hook's decision.
log_event() {
  if command -v foundry_log_event >/dev/null 2>&1; then
    foundry_log_event "$HARNESS_HOME" "$PROJECT" "$(field .session_id)" "$1" "$2" "$3" "${4:--}"
  fi
  return 0
}

# block <hook> <rule> <what happened> <safe alternative> [summary]
block() {
  log_event "$1" "$2" block "${5:-}"
  printf 'BLOCKED by %s [%s]: %s\nSafe alternative: %s\n' "$1" "$2" "$3" "$4" >&2
  exit 2
}

# ask <hook> <rule> <reason> [summary]: force a permission prompt instead of blocking.
ask() {
  log_event "$1" "$2" ask "${4:-}"
  jq -n --arg r "$3" '{hookSpecificOutput: {hookEventName: "PreToolUse",
    permissionDecision: "ask", permissionDecisionReason: $r}}'
  exit 0
}

# segments <command>: one simple command per line (split on && || ; | newline).
# Separators inside quotes do not split, and heredoc bodies are dropped, so
# text in commit messages or echo strings is not mistaken for commands.
# strip_heredocs <command>: same input, heredoc bodies removed, no splitting.
segments() { _shsplit 1 "$1"; }
strip_heredocs() { _shsplit 0 "$1"; }
_shsplit() {
  printf '%s\n' "$2" | awk -v dosplit="$1" '
    function emit() { print out; out = "" }
    hd != "" { if ($0 ~ ("^[\t]*" hd "$")) hd = ""; next }
    {
      line = $0; n = length(line)
      for (i = 1; i <= n; i++) {
        c = substr(line, i, 1)
        if (q != "") { out = out c; if (c == q) q = ""; continue }
        if (c == "\"" || c == "\047") { q = c; out = out c; continue }
        if (c == "<" && substr(line, i, 2) == "<<" && substr(line, i, 3) != "<<<") {
          rest = substr(line, i + 2); skip = 2
          if (substr(rest, 1, 1) == "-") { rest = substr(rest, 2); skip++ }
          if (match(rest, "^[ \t]*[\"\047]?[A-Za-z_][A-Za-z0-9_]*[\"\047]?")) {
            w = substr(rest, 1, RLENGTH); gsub("[ \t\"\047]", "", w); hd = w
            out = out "<<" w; i += skip + RLENGTH - 1; continue
          }
        }
        if (dosplit && (c == ";" || c == "|" || c == "&")) { emit(); continue }
        out = out c
      }
      if (q == "" && dosplit) emit(); else out = out (dosplit ? " " : "\n")
    }
    END { if (out != "") printf "%s%s", out, (dosplit ? "\n" : "") }'
}

# unquote <token>: strip one level of surrounding quotes.
unquote() {
  local t=$1
  t=${t#[\"\']}
  t=${t%[\"\']}
  printf '%s' "$t"
}
