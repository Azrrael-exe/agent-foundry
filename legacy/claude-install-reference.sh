#!/usr/bin/env bash
# Symlink harness config from this repo into ~/.claude. Idempotent.
# A real file/dir (or foreign symlink) at a destination is moved to
# ~/.claude/.harness-replaced/<timestamp>/ before linking.
# bin/* (e.g. harness-report) is linked into ~/.local/bin when it exists.
set -euo pipefail

SRC="$(cd "$(dirname "$0")" && pwd)"
DEST="${CLAUDE_HOME:-$HOME/.claude}"
BIN_DEST="${HARNESS_BIN:-$HOME/.local/bin}"
STASH="$DEST/.harness-replaced/$(date +%Y%m%d-%H%M%S)"

link() { # $1 = path relative to SRC, $2 = destination (default: same path in DEST)
  local src="$SRC/$1" dst="${2:-$DEST/$1}"
  if [ -L "$dst" ] && [ "$(readlink "$dst")" = "$src" ]; then
    echo "ok      $1"
    return
  fi
  mkdir -p "$(dirname "$dst")"
  if [ -e "$dst" ] || [ -L "$dst" ]; then
    mkdir -p "$STASH/$(dirname "$1")"
    if [ -f "$dst" ] && [ ! -L "$dst" ]; then
      diff -u "$dst" "$src" || true
    fi
    mv "$dst" "$STASH/$1"
    echo "backup  $1 -> $STASH/$1"
  fi
  ln -s "$src" "$dst"
  echo "linked  $1"
}

for f in CLAUDE.md settings.json statusline.sh; do
  if [ -e "$SRC/$f" ]; then link "$f"; fi
done
for d in hooks skills agents; do
  [ -d "$SRC/$d" ] || continue
  for entry in "$SRC/$d"/*; do
    if [ -e "$entry" ]; then link "$d/$(basename "$entry")"; fi
  done
done
if [ -d "$SRC/bin" ] && [ -d "$BIN_DEST" ]; then
  for entry in "$SRC/bin"/*; do
    if [ -e "$entry" ]; then link "bin/$(basename "$entry")" "$BIN_DEST/$(basename "$entry")"; fi
  done
fi
