#!/usr/bin/env bash
set -eu
ROOT=$(cd "$(dirname "$0")/../.." && pwd)
python3 "$ROOT/adapters/antigravity/test_hook.py"
