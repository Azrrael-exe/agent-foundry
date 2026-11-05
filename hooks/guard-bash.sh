#!/usr/bin/env bash
# PreToolUse(Bash): block destructive shell commands, ask before local work loss.
# ponytail: token-level parsing, not a shell parser. Variables, eval and
# scripts run later are not seen; see HARNESS.md limitations.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
[ "$TOOL" = Bash ] || exit 0
CMD=$(field .tool_input.command)
[ -n "$CMD" ] || exit 0
H=guard-bash

# --- pipe-to-shell (whole command: must run before splitting on pipes)
sh_re='(sudo[[:space:]]+)?(ba|z|da|k)?sh([[:space:]]|$)'
NOHD=$(strip_heredocs "$CMD")
if [[ $NOHD =~ (curl|wget)[^|]*\|[[:space:]]*$sh_re ]] ||
  [[ $NOHD =~ (ba|z|da|k)?sh[[:space:]]+(-c[[:space:]]+)?[\"\']?(\<\(|\$\()[[:space:]]*(curl|wget) ]]; then
  block $H pipe-to-shell "a remote script is downloaded and executed in one step, without review." \
    "download it to a file (curl -fsSL URL -o script.sh), read it, then run it explicitly." "curl|sh"
fi

real_home=$(cd "$HOME" 2>/dev/null && pwd -P)
real_root=$(cd "$PROJECT" 2>/dev/null && pwd -P)

# resolve <path>: absolute physical path of an rm target (parent resolved,
# so a symlink target is the link itself). Empty if unresolvable.
resolve() {
  local p=$1 base dir d suffix="" out
  # shellcheck disable=SC2088,SC2016 # literal ~ and $HOME as typed by the model
  case $p in
  "~" | "~/"*) p=$HOME${p#\~} ;;
  '$HOME' | '$HOME/'*) p=$HOME${p#\$HOME} ;;
  '${HOME}' | '${HOME}/'*) p=$HOME${p#\$\{HOME\}} ;;
  esac
  case $p in *'$'* | *'`'*) return ;; esac # unexpanded variable: fail open
  # Cut at the first glob component: rm acts on that directory's contents.
  [[ $p == *[\*\?\[]* ]] && p=${p%%[\*\?\[]*} && p=${p%/*}/
  [[ $p == /* ]] || p=$CWD/$p
  while [[ $p == */ && $p != / ]]; do p=${p%/}; done
  base=${p##*/}
  case $base in
  "" | . | ..) dir=$p base="" ;;
  *) dir=${p%/*} && dir=${dir:-/} ;;
  esac
  d=$dir # nearest existing ancestor, then physical path
  while [ ! -d "$d" ]; do suffix=/${d##*/}$suffix d=$(dirname "$d"); done
  d=$(cd "$d" && pwd -P) || return
  out=${d%/}$suffix
  [ -n "$base" ] && out=$out/$base
  printf '%s' "${out:-/}"
}

is_temp() {
  case $1 in /tmp | /tmp/* | /private/tmp/* | /var/folders/* | /private/var/folders/*) return 0 ;; esac
  [ -n "${TMPDIR:-}" ] && [[ $1 == "${TMPDIR%/}"/* ]]
}

check_rm() {
  local t r="" f="" target real
  for t in "$@"; do
    case $t in
    --recursive) r=1 ;;
    --force) f=1 ;;
    --*) ;;
    -*)
      [[ $t == *[rR]* ]] && r=1
      [[ $t == *f* ]] && f=1
      ;;
    esac
  done
  [ -n "$r" ] && [ -n "$f" ] || return 0
  for t in "$@"; do
    [[ $t == -* ]] && continue
    target=$(unquote "$t")
    real=$(resolve "$target")
    [ -n "$real" ] || continue
    if [ "$real" = / ] || [ "$real" = "$real_home" ] || [ "$real" = "$real_root" ]; then
      block $H rm-outside-project "rm -rf on '$target' (resolves to $real) would delete / , your home or the whole project." \
        "delete specific paths inside the project, or ask me to run it myself." rm
    fi
    is_temp "$real" && continue
    if [[ $real != "$real_root"/* ]]; then
      block $H rm-outside-project "rm -rf on '$target' (resolves to $real) is outside the project ($real_root)." \
        "only delete paths inside the project or a temp dir; ask me to delete anything else." rm
    fi
  done
}

check_git() { # $1 = -C dir or "", then subcommand and args
  local dir=$1 sub=$2 t force="" args=() dst
  shift 2
  case $sub in
  reset)
    for t in "$@"; do [ "$t" = --hard ] && ask $H reset-hard "git reset --hard discards uncommitted work. Run 'git stash' first if unsure." "git reset"; done
    ;;
  clean)
    for t in "$@"; do
      if [ "$t" = --force ] || [[ $t =~ ^-[a-zA-Z]*f ]]; then
        ask $H clean-force "git clean -f permanently deletes untracked files. Preview with 'git clean -n' first." "git clean"
      fi
    done
    ;;
  push)
    for t in "$@"; do
      case $t in
      --force | --force-with-lease | --force-with-lease=* | --force-if-includes) force=1 ;;
      --*) ;;
      -*) [[ $t == *f* ]] && force=1 ;;
      *) args+=("$t") ;;
      esac
    done
    # args[0] is the remote; the rest are refspecs.
    if [ "${#args[@]}" -le 1 ]; then
      dst=$(git -C "${dir:-$CWD}" rev-parse --abbrev-ref HEAD 2>/dev/null)
      set -- "$dst"
    else
      set -- "${args[@]:1}"
    fi
    for t in "$@"; do
      [[ $t == +* ]] && force=1
      dst=${t#+}
      dst=${dst##*:}
      dst=${dst#refs/heads/}
      if [ -n "$force" ] && { [ "$dst" = main ] || [ "$dst" = master ]; }; then
        block $H force-push-protected "force push to '$dst' rewrites shared history." \
          "push without --force, push to a new branch and open a PR, or ask me to do it." "git push"
      fi
    done
    ;;
  esac
}

while IFS= read -r seg; do
  read -ra tok <<<"$seg"
  # Skip leading wrappers and env assignments.
  while [ "${#tok[@]}" -gt 0 ]; do
    # shellcheck disable=SC2016 # literal "$(" token
    case ${tok[0]} in
    sudo | command | time | nohup | exec | '(' | '{' | '$(') tok=("${tok[@]:1}") ;;
    [A-Za-z_]*=*) tok=("${tok[@]:1}") ;;
    *) break ;;
    esac
  done
  [ "${#tok[@]}" -gt 0 ] || continue
  tok[0]=${tok[0]#\(}
  case ${tok[0]} in
  rm) check_rm "${tok[@]:1}" ;;
  chmod)
    rec="" mode=""
    for t in "${tok[@]:1}"; do
      case $t in
      --recursive) rec=1 ;;
      777 | 0777 | a+rwx | ugo+rwx) mode=1 ;;
      -*) [[ $t == *R* ]] && rec=1 ;;
      esac
    done
    if [ -n "$rec" ] && [ -n "$mode" ]; then
      block $H chmod-777-recursive "chmod -R 777 makes every file world-writable." \
        "grant the minimum needed, e.g. chmod -R u+rwX,go+rX <dir>." chmod
    fi
    ;;
  git)
    i=1 dir=""
    while [ "$i" -lt "${#tok[@]}" ]; do
      case ${tok[$i]} in
      -C) dir=$(unquote "${tok[$((i + 1))]:-}") && i=$((i + 2)) ;;
      -c) i=$((i + 2)) ;;
      -*) i=$((i + 1)) ;;
      *) break ;;
      esac
    done
    [ "$i" -lt "${#tok[@]}" ] && check_git "$dir" "${tok[@]:$i}"
    ;;
  esac
done < <(segments "$CMD")
exit 0
