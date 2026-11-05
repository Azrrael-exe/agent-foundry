# shellcheck shell=bash
# Pattern-based helpers; these catch common credential forms, not all secrets.
# These helpers do not read a path or perform logging.
foundry_secret_path() {
  local p=$1 b
  case $p in "~"/*) p=$HOME${p#\~} ;; esac
  b=${p##*/}
  case $b in .env.example | .env.sample | .env.template | *.pub) return 1 ;; esac
  case $b in
    .env | .env.* | *.pem | *.key | *.p12 | *.pfx | id_rsa* | id_ed25519* | id_ecdsa* | \
      credentials*.json | .netrc | .npmrc | .pypirc | .claude.json | claude_mcp_config.json) return 0 ;;
  esac
  case $p in
    "$HOME"/.ssh/* | "$HOME"/.aws/* | "$HOME"/.gnupg/* | "$HOME"/.config/gcloud/* | \
      "$HOME"/.config/gh/hosts.yml) return 0 ;;
  esac
  return 1
}

foundry_secret_content() {
  local secret_re='-----BEGIN ([A-Z0-9]+ )*PRIVATE KEY-----|(^|[^A-Za-z0-9_])((AKIA|ASIA)[0-9A-Z]{16}|gh[pousr]_[A-Za-z0-9]{36,}|github_pat_[A-Za-z0-9_]{22,}|sk-ant-[A-Za-z0-9_-]{20,}|sk-(proj-)?[A-Za-z0-9]{20,}|xox[abposr]-[A-Za-z0-9-]{10,}|AIza[0-9A-Za-z_-]{35}|(sk|rk)_live_[0-9A-Za-z]{24,})'
  printf '%s' "$1" | grep -Eq -e "$secret_re"
}
