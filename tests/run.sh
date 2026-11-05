#!/usr/bin/env bash
set -euo pipefail
root=$(cd "$(dirname "$0")/.." && pwd)
for suite in "$root"/tests/*/run.sh; do
  printf '\n==> %s\n' "${suite#"$root"/}"
  "$suite"
done
