# shellcheck shell=bash
# Provider-neutral trust lookup. The first argument is a trust-list file and
# the second is the project directory. Entries name existing directories;
# descendants are trusted after resolving symlinks in both paths.
foundry_is_trusted() {
  local file=$1 project=$2 d line
  [ -f "$file" ] || return 1
  d=$(cd "$project" 2>/dev/null && pwd -P) || return 1
  while IFS= read -r line || [ -n "$line" ]; do
    line=${line%%#*}
    line=${line#"${line%%[![:space:]]*}"}
    line=${line%"${line##*[![:space:]]}"}
    # shellcheck disable=SC2088 # literal ~ as written in the file
    case $line in "~" | "~/"*) line=$HOME${line#\~} ;; esac
    [ -n "$line" ] || continue
    line=$(cd "$line" 2>/dev/null && pwd -P) || continue
    if [ "$d" = "$line" ] || [[ $d == "$line"/* ]]; then return 0; fi
  done <"$file"
  return 1
}
