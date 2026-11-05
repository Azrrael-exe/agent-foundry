#!/usr/bin/env bash
# PostToolUse(Edit|Write): format and lint the edited file with the tools the
# project has configured. Silent when nothing applies or a tool is missing.
# Disable per project with env HARNESS_FORMAT=off.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
[ "${HARNESS_FORMAT:-}" = off ] && exit 0
FILE=$(field .tool_input.file_path)
[ -f "$FILE" ] || exit 0
root=$(cd "$PROJECT" 2>/dev/null && pwd -P) || exit 0
dir=$(cd "$(dirname "$FILE")" && pwd -P) || exit 0
FILE=$dir/${FILE##*/}
[[ $FILE == "$root"/* ]] || exit 0 # only files inside the project

# up <relpath>: nearest <dir>/<relpath>, from the file's dir up to the project root.
up() {
  local d=$dir
  while :; do
    if [ -e "$d/$1" ]; then printf '%s' "$d/$1" && return 0; fi
    if [ "$d" = "$root" ] || [ "$d" = / ]; then return 1; fi
    d=$(dirname "$d")
  done
}

# run <tool> <cmd...>: on failure, show the output to Claude and exit 2.
run() {
  local tool=$1 out
  shift
  out=$("$@" 2>&1) && return 0
  log_event format-on-edit "$tool" block "$tool .${FILE##*.}"
  printf 'format-on-edit [%s]: %s was saved but %s reported problems:\n%s\nFix them, or tell me why they should stay.\n' \
    "$tool" "$FILE" "$tool" "$(printf '%s\n' "$out" | tail -n 40)" >&2
  exit 2
}

case $FILE in
*.py | *.pyi)
  cfg=""
  if pp=$(up pyproject.toml) && grep -q '^\[tool\.ruff' "$pp"; then cfg=1; fi
  if up ruff.toml >/dev/null || up .ruff.toml >/dev/null; then cfg=1; fi
  [ -n "$cfg" ] || exit 0
  # Repo-local binaries are repo code: only in trusted projects.
  ruff=""
  if is_trusted "$root"; then ruff=$(up .venv/bin/ruff); fi
  [ -n "$ruff" ] || ruff=$(command -v ruff) || exit 0
  # --force-exclude: honour the project's exclude even for an explicit path.
  run ruff "$ruff" format -q --force-exclude "$FILE"
  run ruff "$ruff" check -q --force-exclude "$FILE"
  ;;
*.js | *.jsx | *.ts | *.tsx | *.mjs | *.cjs | *.json | *.css | *.scss | *.md | *.yaml | *.yml | *.html | *.vue)
  is_trusted "$root" || exit 0
  prettier=$(up node_modules/.bin/prettier) || exit 0
  run prettier "$prettier" --write "$FILE"
  ;;
*.go)
  command -v gofmt >/dev/null 2>&1 || exit 0
  run gofmt gofmt -l -w "$FILE"
  ;;
*.sh | *.bash)
  if up .editorconfig >/dev/null && command -v shfmt >/dev/null 2>&1; then
    run shfmt shfmt -w "$FILE"
  fi
  if up .shellcheckrc >/dev/null && command -v shellcheck >/dev/null 2>&1; then
    run shellcheck shellcheck -S warning "$FILE"
  fi
  ;;
esac
exit 0
