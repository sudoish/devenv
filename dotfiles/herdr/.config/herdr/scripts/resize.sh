#!/bin/sh
# Resize the focused pane by a fixed number of cells, like tmux `resize-pane -L 5`.
# Herdr resizes by a fraction of the split, so convert cells to that fraction.
# Usage: resize.sh left|down|up|right [cells]
herdr=${HERDR_BIN_PATH:-herdr}
pane=$HERDR_ACTIVE_PANE_ID
cells=${2:-5}

case $1 in
  left | right) split=right size=width ;;
  up | down) split=down size=height ;;
  *) exit 1 ;;
esac

# The split being resized is the smallest one in that orientation that contains the pane.
amount=$("$herdr" pane layout --pane "$pane" | jq -r --arg pane "$pane" \
  --arg split "$split" --arg size "$size" --argjson cells "$cells" '
  .result.layout as $l
  | ($l.panes[] | select(.pane_id == $pane) | .rect) as $p
  | [$l.splits[] | select(.direction == $split) | .rect
     | select(.x <= $p.x and .y <= $p.y
              and .x + .width >= $p.x + $p.width
              and .y + .height >= $p.y + $p.height)
     | .[$size]]
  | min // empty
  | $cells / .')

[ -n "$amount" ] && "$herdr" pane resize --direction "$1" --amount "$amount" --pane "$pane"
