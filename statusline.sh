#!/usr/bin/env bash
# Claude Code status line: model │ dir │ branch* │ untrusted │ ctx % │ cost │ HARNESS OFF
# Uses only documented stdin fields. '*' = staged or unstaged changes
# (untracked files are ignored: too slow to scan in big repos).
US=$'\x1f' # field separator that `read` does not collapse, unlike tab
IFS=$US read -r model dir proj ctx cost < <(jq -r --arg s "$US" '[
  .model.display_name // "?",
  .workspace.current_dir // .cwd // "",
  .workspace.project_dir // .workspace.current_dir // .cwd // "",
  (.context_window.used_percentage // "" | tostring),
  (.cost.total_cost_usd // "" | tostring)] | join($s)' 2>/dev/null)

model=${model:-?}
DIM=$'\033[2m' RED=$'\033[31m' YEL=$'\033[33m' RST=$'\033[0m'
parts=("$model" "${dir##*/}")

g() { git -C "$dir" --no-optional-locks "$@" 2>/dev/null; }
if [ -n "$dir" ] && g rev-parse --is-inside-work-tree >/dev/null; then
  b=$(g branch --show-current)
  [ -n "$b" ] || b=$(g rev-parse --short HEAD)
  { g diff --quiet && g diff --cached --quiet; } || b="$b*"
  parts+=("$b")
  # Repo code (check command, repo-local formatters) does not run here.
  # shellcheck source=hooks/trust.sh
  . "$(dirname "$0")/hooks/trust.sh"
  is_trusted "${proj:-$dir}" || parts+=("${YEL}untrusted$RST")
fi

if [ -n "$ctx" ]; then
  pct=${ctx%.*}
  c="ctx $pct%"
  if [ "$pct" -ge 90 ]; then c=$RED$c$RST; elif [ "$pct" -ge 70 ]; then c=$YEL$c$RST; fi
  parts+=("$c")
else
  parts+=("ctx --")
fi
if [ -n "$cost" ]; then parts+=("$(LC_ALL=C printf '$%.2f' "$cost")"); fi
if [ "${HARNESS_OFF:-}" = 1 ]; then parts+=("${RED}HARNESS OFF$RST"); fi

out=${parts[0]}
for p in "${parts[@]:1}"; do out+=" $DIM│$RST $p"; done
printf '%s\n' "$out"
