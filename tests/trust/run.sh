#!/usr/bin/env bash
# shellcheck disable=SC2016,SC2088 # Literal shell code and tilde are test inputs.
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
TMP=$(mktemp -d)
trap 'rm -rf "$TMP"' EXIT
# shellcheck source=../../core/trust.sh
. "$ROOT/core/trust.sh"
mkdir -p "$TMP/trusted/child" "$TMP/trusted-sibling" "$TMP/outside" "$TMP/state" "$TMP/links"
ln -s "$TMP/outside" "$TMP/trusted/escape"
ln -s "$TMP/trusted/child" "$TMP/alias"
ln -s "$ROOT/hooks/trust.sh" "$TMP/links/trust.sh"
list="$TMP/state/trusted-projects"
check() { if "$@"; then printf 'OK    %s\n' "$description"; else printf 'FAIL  %s\n' "$description"; exit 1; fi; }
denied() { if foundry_is_trusted "$@"; then return 1; else return 0; fi; }
description='missing trust list denies'; check denied "$list" "$TMP/trusted"
printf '  %s  # trusted root\n' "$TMP/trusted" >"$list"
description='root is trusted'; check foundry_is_trusted "$list" "$TMP/trusted"
description='child is trusted'; check foundry_is_trusted "$list" "$TMP/trusted/child"
description='sibling is denied'; check denied "$list" "$TMP/trusted-sibling"
description='symlink escaping root is denied'; check denied "$list" "$TMP/trusted/escape"
description='symlink into root is trusted'; check foundry_is_trusted "$list" "$TMP/alias"
description='missing project is denied'; check denied "$list" "$TMP/missing"
printf '~/trusted\n' >"$list"
description='tilde expands against HOME'; check env HOME="$TMP" bash -c '. "$1"; foundry_is_trusted "$2" "$3"' _ "$ROOT/core/trust.sh" "$list" "$TMP/trusted"
printf '%s\n' "$TMP/trusted" >"$list"
description='Claude wrapper works through installer symlink'; check env HARNESS_HOME="$TMP/state" bash -c '. "$1"; is_trusted "$2"' _ "$TMP/links/trust.sh" "$TMP/trusted/child"
