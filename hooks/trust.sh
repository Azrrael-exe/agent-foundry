# shellcheck shell=bash
# Trust list for code that comes from a repository (check commands,
# repo-local formatter binaries). Sourced by lib.sh and statusline.sh.
# File: one path per line, '#' comments, '~' expanded; a project is trusted
# when its real path equals a listed path or is below it.

HARNESS_HOME=${HARNESS_HOME:-$HOME/.claude/harness}

# The legacy installer links individual hook files into ~/.claude/hooks.
# Resolve that link before locating the shared implementation.
_foundry_trust_source=${BASH_SOURCE[0]}
if [ -L "$_foundry_trust_source" ]; then
  _foundry_trust_link=$(readlink "$_foundry_trust_source")
  case $_foundry_trust_link in
    /*) _foundry_trust_source=$_foundry_trust_link ;;
    *) _foundry_trust_source=${_foundry_trust_source%/*}/$_foundry_trust_link ;;
  esac
  unset _foundry_trust_link
fi
# shellcheck source=../core/trust.sh
. "${_foundry_trust_source%/*}/../core/trust.sh"
unset _foundry_trust_source

is_trusted() { foundry_is_trusted "$HARNESS_HOME/trusted-projects" "$1"; }
