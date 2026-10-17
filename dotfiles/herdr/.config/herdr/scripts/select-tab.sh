#!/bin/sh
# Prompt for a tab number and jump to it, like tmux `command-prompt "select-window -t :%%"`.
herdr=${HERDR_BIN_PATH:-herdr}

printf 'Tab number: '
read -r number || exit 0
[ -n "$number" ] || exit 0

tab=$("$herdr" tab list --workspace "$HERDR_ACTIVE_WORKSPACE_ID" |
  jq -r --arg n "$number" '.result.tabs[] | select((.number | tostring) == $n) | .tab_id')

if [ -n "$tab" ]; then
  "$herdr" tab focus "$tab" >/dev/null
else
  printf 'No tab %s\n' "$number"
  sleep 1
fi
