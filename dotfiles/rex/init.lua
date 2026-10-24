--
-- Mirrors the tmux (dotfiles/tmux/.tmux.conf) and Herdr (dotfiles/herdr) key
-- scheme: ctrl+a prefix, vim-style pane movement, shift+arrows to resize.
-- Rex terms: session = tmux session / Herdr workspace, tab = tmux window /
-- Herdr tab, pane = tmux / Herdr pane.
--
-- Appearance (theme, font, cursor style) is not configurable from this file;
-- Rex keeps it in the app's settings and rex.yaml sets those to match Ghostty.
-- Validate with `rex config check`, apply with `rex config reload` (prefix+r).

local terminal = "com.superlogical.terminal"
local prefix = "ctrl+a"

local function p(key)
  return prefix .. ">" .. key
end

-- Working directory of the focused terminal, so new tabs follow it like
-- Herdr's new_cwd = "follow" and tmux's -c "#{pane_current_path}".
local function current_cwd()
  local ok, proc = pcall(rex.block.call, terminal, "process", {})
  if not ok or not proc then
    return nil
  end
  if proc.foreground and proc.foreground.cwd then
    return proc.foreground.cwd
  end
  for _, ancestor in ipairs(proc.ancestors or {}) do
    if ancestor.cwd then
      return ancestor.cwd
    end
  end
  return proc.home
end

local function open_tab(label, command)
  return rex.session.new_window{
    window_label = label,
    layout = rex.layout.block{
      flavor = terminal .. ".shell",
      options = { cwd = current_cwd(), command = command },
    },
  }
end

-- tmux `new-window -n %%` / Herdr prompt_new_tab_name: open the tab, then ask for its name.
-- The follow-up client actions are only accepted when the key is pressed in the app;
-- running the action from the CLI needs Remote Control (Settings -> Rex Server).
rex.action{
  name = "tab_new_named",
  title = "New Tab in Current Directory (named)",
  category = "Tab",
  run = function(ctx)
    local created, err = open_tab(nil)
    if not created then
      error(err)
    end
    -- Ask the app directly and wait for each answer, so the rename prompt
    -- opens on the new tab instead of the one that was selected before.
    local function perform(action, args, block_id)
      local result, perform_err = rex.call("client.perform", {
        client_id = ctx.client_id,
        session_id = ctx.session_id,
        block_id = block_id,
        action = action,
        args = args,
        origin = "key",
      })
      if not result then
        rex.log("warn", "tab_new_named: " .. action .. " failed: " .. tostring(perform_err))
      end
      return result
    end
    if perform("session.select", { session_id = ctx.session_id, window_id = created.window_id }) then
      rex.exec({ "sleep", "0.3" }) -- give the app a moment to finish switching tabs
      perform("client.tab.rename", nil, created.block_ids[1])
    else
      -- Fallback when the app refuses direct requests: queue the switch and the rename.
      rex.client.queue("client.tab.goto", { index = -1 })
      rex.client.queue("client.tab.rename")
    end
  end,
}

-- tmux `new-window -n opencode -c "#{pane_current_path}" opencode`: the tab closes when OpenCode exits.
rex.action{
  name = "opencode_tab",
  title = "Open OpenCode Tab",
  category = "Tab",
  run = function()
    open_tab("opencode", { "opencode" })
  end,
}

-- cmd+1..9: jump to the Nth session in server order (new sessions go at the end).
rex.action{
  name = "session_goto",
  title = "Go to Session by Number",
  category = "Session",
  args = { index = "integer" },
  run = function(ctx, args)
    local list, err = rex.call("session.list", {})
    if not list then
      error(err)
    end
    local target = (list.sessions or {})[args.index]
    if target then
      rex.client.queue("session.select", { session_id = target.session_id })
    end
  end,
}

-- vim-tmux-navigator: ctrl+h/j/k/l moves between panes, unless Vim or fzf is
-- in the foreground, in which case the key goes to the program.
local function is_vim_like(name)
  name = name:gsub("^g", ""):gsub("diff$", "")
  return name == "view" or name == "fzf" or name:match("^l?n?vim?x?$") ~= nil
end

local function navigate(direction)
  return function()
    local ok, proc = pcall(rex.block.call, terminal, "process", {})
    local foreground = ok and proc and proc.foreground and proc.foreground.name or ""
    if is_vim_like(foreground) then
      return false -- not handled: the key reaches the program
    end
    rex.session.focus_direction{ direction = direction, wrap = false }
    return true
  end
end

local directions = { h = "left", j = "down", k = "up", l = "right" }

for key, direction in pairs(directions) do
  rex.bind("ctrl+" .. key, navigate(direction))
  rex.bind(p(key), "pane.focus." .. direction)
end

-- Prefix twice sends ctrl+a to the program (tmux `bind-key C-a send-prefix`).
rex.bind(p(prefix), "pane.send_key", { key = prefix })

-- Tabs (tmux windows)
rex.bind(p("c"), "tab_new_named")
rex.bind(p(","), "client.tab.rename")
rex.bind(p("p"), "client.tab.previous")
Add Rex number keys for tabs and sessions

ctrl+1..9 jumps to the Nth tab and cmd+1..9 to the Nth session. Sessions
have no built-in go-to-by-number action, so a session_goto action looks
the session up from session.list and asks the app to show it.

Co-Authored-By: Claude Fable 5.1 <noreply@anthropic.com>
rex.bind(p("shift+right"), "client.tab.next")
rex.bind(p("shift+7"), "client.tab.close") -- &
rex.bind(p("o"), "opencode_tab")
for i = 1, 9 do
  rex.bind(p(tostring(i)), "client.tab.goto", { index = i })
  rex.bind("ctrl+" .. tostring(i), "client.tab.goto", { index = i })
  rex.bind("cmd+" .. tostring(i), "session_goto", { index = i })
end

-- Sessions (tmux sessions / Herdr workspaces)
rex.bind(p("shift+4"), "session.rename") -- $
-- Sessions live in the Rex server (a launchd agent), so closing the app window only
-- detaches like tmux prefix+d; the session keeps running and reappears when Rex reopens.
rex.bind(p("d"), "client.window.close")
rex.bind(p("w"), "session.switch") -- tmux prefix+w: choose a session
rex.bind(p("shift+9"), "session.previous") -- (
rex.bind(p("shift+0"), "session.next") -- )

-- Panes
rex.bind(p("v"), "pane.split.right")
rex.bind(p("s"), "pane.split.down")
rex.bind(p(";"), "pane.focus_previous")
rex.bind(p("z"), "pane.zoom")
rex.bind(p("x"), "pane.close")

-- App
rex.bind(p("r"), "client.config.reload")
rex.bind(p("shift+s"), "client.settings")

-- Resize: shift+arrows nudge the focused pane (tmux `bind -n S-Left resize-pane -L 5`);
-- the Ghostty-style super+ctrl+shift+alt+arrows chord resizes in big steps.
-- Rex resizes by percent of the split, not by cells.
for _, direction in ipairs({ "left", "right", "up", "down" }) do
  rex.bind("shift+" .. direction, "pane.resize", { direction = direction, amount = 5 })
  rex.bind("cmd+ctrl+shift+alt+" .. direction, "pane.resize", { direction = direction, amount = 100 })
end

-- Herdr resize mode (prefix+shift+r): h/j/k/l or arrows resize, enter/escape/q leave.
rex.mode("resize", { exclusive = true })
rex.bind(p("shift+r"), "client.mode.enter", { name = "resize" })
for key, direction in pairs(directions) do
  rex.bind("resize/" .. key, "pane.resize", { direction = direction, amount = 5 })
  rex.bind("resize/" .. direction, "pane.resize", { direction = direction, amount = 5 })
end
rex.bind("resize/enter", "client.mode.exit")
rex.bind("resize/q", "client.mode.exit")

-- Send Shift+Enter and Alt+Shift+Enter as CSI-u so TUIs (Claude Code, tmux,
-- Herdr) can tell them apart from plain Enter. Mirrors the Ghostty keybinds.
local function send(data)
  return function()
    rex.block.call(terminal, "write", { data = data })
    return true
  end
end

rex.bind("shift+enter", send("\27[13;2u"))
rex.bind("alt+shift+enter", send("\27[13;4u"))
