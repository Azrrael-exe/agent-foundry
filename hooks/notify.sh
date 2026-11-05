#!/usr/bin/env bash
# Notification: native macOS notification when Claude needs input.
# The matcher in settings.json limits it to "needs you" notification types.
# shellcheck source=lib.sh
. "$(dirname "$0")/lib.sh"
command -v osascript >/dev/null 2>&1 || exit 0 # not macOS
msg=$(field .message)
# Text goes in as argv, never interpolated into the AppleScript source.
osascript -e 'on run argv' \
  -e 'display notification (item 1 of argv) with title (item 2 of argv) subtitle (item 3 of argv) sound name "Glass"' \
  -e 'end run' "${msg:-Claude needs your input}" "Claude Code" "${PROJECT##*/}" >/dev/null 2>&1
exit 0
