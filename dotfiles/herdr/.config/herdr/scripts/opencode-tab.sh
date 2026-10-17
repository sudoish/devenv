#!/bin/sh
# Open OpenCode in a new tab named "opencode" in the current directory,
# like tmux `new-window -n opencode -c "#{pane_current_path}" opencode`.
herdr=${HERDR_BIN_PATH:-herdr}

pane=$("$herdr" tab create --workspace "$HERDR_ACTIVE_WORKSPACE_ID" --label opencode \
  --cwd "${HERDR_ACTIVE_PANE_CWD:-$HOME}" --focus | jq -r '.result.root_pane.pane_id')

# exec so the tab closes when OpenCode exits, as the tmux window did.
"$herdr" pane run "$pane" "exec opencode" >/dev/null
