# shellcheck shell=bash
# shellcheck disable=SC2034 # FOUNDRY_CHECK is the function's output for callers.
# Discover a check in the current project directory. On success, populate
# FOUNDRY_CHECK as an argv array; return 1 when no supported check exists.
# This does not establish trust: callers must authorize repository code first.
foundry_find_check() {
  local f
  FOUNDRY_CHECK=()
  if [ -x .harness/check.sh ]; then
    FOUNDRY_CHECK=(.harness/check.sh)
    return 0
  fi
  if [ -x .claude/check.sh ]; then
    FOUNDRY_CHECK=(.claude/check.sh)
    return 0
  fi
  if command -v just >/dev/null 2>&1; then
    for f in justfile Justfile .justfile; do
      if [ -f "$f" ] && just --summary 2>/dev/null | tr ' ' '\n' | grep -qx check; then
        FOUNDRY_CHECK=(just check)
        return 0
      fi
    done
  fi
  for f in GNUmakefile makefile Makefile; do
    # Match targets, not variable assignments such as `check := value`.
    if [ -f "$f" ] && grep -qE '^check[[:space:]]*::?([^=:]|$)' "$f"; then
      FOUNDRY_CHECK=(make check)
      return 0
    fi
  done
  return 1
}
