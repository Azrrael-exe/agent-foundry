#!/usr/bin/env bash
# PreToolUse(Bash|Read|Edit|Write): block access to secret files and
# key-like content about to be written or run.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
H=guard-secrets

PATH_ALT="use a .env.example with fake values, or ask me for the specific value you need."
CONTENT_ALT="read it from an environment variable (os.environ / process.env) and never write it to a file."

# The legacy installer links individual hooks. Locate the shared rules at the
# link target, not relative to the ~/.claude/hooks directory.
secret_source=${BASH_SOURCE[0]}
if [ -L "$secret_source" ]; then
  secret_link=$(readlink "$secret_source")
  case $secret_link in
    /*) secret_source=$secret_link ;;
    *) secret_source=${secret_source%/*}/$secret_link ;;
  esac
  unset secret_link
fi
# shellcheck source=../core/secrets.sh
. "${secret_source%/*}/../core/secrets.sh" || { printf '%s\n' 'guard-secrets: missing shared rules' >&2; exit 2; }
unset secret_source

check_content() { # $1 = text, $2 = where
  if foundry_secret_content "$1"; then
    block $H secret-content "$2 contains what looks like a credential (API key, token or private key)." "$CONTENT_ALT" "$TOOL"
  fi
}

case $TOOL in
Read | Edit | Write)
  FILE=$(field .tool_input.file_path)
  if [ -n "$FILE" ] && foundry_secret_path "$FILE"; then
    block $H secret-path "$TOOL on '$FILE', which is a secrets or credentials file." "$PATH_ALT" "$TOOL ${FILE##*/}"
  fi
  [ "$TOOL" = Write ] && check_content "$(field .tool_input.content)" "The content to write"
  [ "$TOOL" = Edit ] && check_content "$(field .tool_input.new_string)" "The edit"
  ;;
Bash)
  CMD=$(field .tool_input.command)
  [ -n "$CMD" ] || exit 0
  check_content "$CMD" "The command"
  while IFS= read -r seg; do
    read -ra tok <<<"$seg"
    [ "${#tok[@]}" -gt 0 ] || continue
    reader=
    case ${tok[0]} in
    cat | less | more | head | tail | grep | rg | awk | sed | cp | mv | scp | base64 | xxd | strings | source | . | open) reader=1 ;;
    esac
    for t in "${tok[@]:1}"; do
      t=$(unquote "$t")
      case $t in "<"*) t=${t#<} && reader=1 ;; esac
      [ -n "$t" ] || continue
      if [ -n "$reader" ] && foundry_secret_path "$t"; then
        block $H secret-path-bash "'${tok[0]}' would read or copy '$t', which is a secrets or credentials file." "$PATH_ALT" "${tok[0]} ${t##*/}"
      fi
    done
  done < <(segments "$CMD")
  ;;
esac
exit 0
