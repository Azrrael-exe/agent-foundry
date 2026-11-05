# shellcheck shell=bash
# Git state helpers. Call from the project directory with state stored outside
# the project. The caller controls trust, event mapping, and check execution.
foundry_gate_fingerprint() {
  {
    git status --porcelain
    git diff HEAD --binary --no-ext-diff --no-textconv
    git ls-files -o --exclude-standard -z | xargs -0 shasum
  } 2>/dev/null | shasum | cut -d' ' -f1
}

foundry_gate_set_base() {
  local state=$1
  foundry_gate_fingerprint >"$state.base.tmp" && mv "$state.base.tmp" "$state.base"
}

foundry_gate_needs_check() {
  local state=$1 key last
  [ -n "$(git status --porcelain 2>/dev/null)" ] || return 1
  if [ ! -f "$state.base" ]; then
    if foundry_gate_set_base "$state"; then return 1; fi
  fi
  key=$(foundry_gate_fingerprint)
  [ "$(cat "$state.base")" = "$key" ] && return 1
  last=$(cat "$state.last" 2>/dev/null)
  [ "${last#* }" = "$key" ] && return 1
  return 0
}

foundry_gate_record() {
  local state=$1 result=$2
  printf '%s %s\n' "$result" "$(foundry_gate_fingerprint)" >"$state.last"
}
