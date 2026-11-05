#!/usr/bin/env bash
# PreToolUse(Bash) for read-only agents (registered in agent frontmatter, not
# globally): allow only read-only git commands and output filters.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
[ "$TOOL" = Bash ] || exit 0
CMD=$(field .tool_input.command)
[ -n "$CMD" ] || exit 0
H=git-readonly

deny() {
  local w
  read -ra w <<<"$1"
  # summary: command name only (plus the git subcommand), never arguments.
  if [ "${w[0]}" = git ]; then w[0]="git ${w[1]:-}"; fi
  block $H non-readonly-command "'$1' is not allowed: this agent may only run read-only git commands and output filters." \
    "use Read/Grep/Glob for files, and git status/diff/log/show/blame for history." "${w[0]}"
}

# Harmless redirections would otherwise split into bogus segments.
CMD=${CMD//2>&1/}
CMD=${CMD//2>\/dev\/null/}

while IFS= read -r seg; do
  read -ra tok <<<"$seg"
  [ "${#tok[@]}" -gt 0 ] || continue
  for t in "${tok[@]}"; do
    # shellcheck disable=SC2016 # literal "$(" to detect command substitution
    case $t in
    *'$('* | *'`'*) deny "$seg" ;;  # command substitution
    '>'* | [0-9]'>'*) deny "$seg" ;; # writes a file
    esac
  done
  case ${tok[0]} in
  head | tail | wc | sort | uniq | cut | grep) continue ;;
  git) ;;
  *) deny "$seg" ;;
  esac
  i=1
  while [ "$i" -lt "${#tok[@]}" ]; do
    case ${tok[$i]} in
    -C) i=$((i + 2)) ;;
    --no-pager) i=$((i + 1)) ;;
    *) break ;; # anything else, including -c, is the subcommand slot
    esac
  done
  sub=${tok[$i]:-}
  for t in "${tok[@]:$i}"; do
    case $t in --output | --output=* | --ext-diff | -O* | --open-files-in-pager*) deny "$seg" ;; esac
  done
  case $sub in
  status | diff | log | show | blame | rev-parse | merge-base | ls-files | grep | describe | shortlog | cat-file | for-each-ref) ;;
  branch)
    for t in "${tok[@]:$((i + 1))}"; do
      case $t in --show-current | -a | -r | -v | -vv | --list | --all | --remotes | --verbose | --no-color) ;; *) deny "$seg" ;; esac
    done
    ;;
  *) deny "$seg" ;;
  esac
done < <(segments "$CMD")
exit 0
