#!/bin/sh
# vim-tmux-navigator for Herdr: ctrl+h/j/k/l goes to Vim when it is the
# foreground program, otherwise it moves focus to the neighbouring pane.
# Usage: navigate.sh left|down|up|right
herdr=${HERDR_BIN_PATH:-herdr}
pane=$HERDR_ACTIVE_PANE_ID

case $1 in
  left) key=ctrl+h ;;
  down) key=ctrl+j ;;
  up) key=ctrl+k ;;
  right) key=ctrl+l ;;
  *) exit 1 ;;
esac

if "$herdr" pane process-info --pane "$pane" |
  grep -Eq '"name":"g?(view|l?n?vim?x?|fzf)(diff)?"'; then
  "$herdr" pane send-keys "$pane" "$key"
else
  "$herdr" pane focus --direction "$1" --pane "$pane"
fi
