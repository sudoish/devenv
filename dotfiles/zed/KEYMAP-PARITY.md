# Zed ⇄ nvim keymap parity

Tracks the nvim (NvChad) leader/nav muscle memory against the Zed `keymap.json`
after the tmux+nvim → Zed cutover. **Not a closed scope** — parity arrives in
clusters; this is the running checklist. Source of truth for nvim bindings:
`~/.config/nvim/lua/mappings.lua` + `lua/plugins/*.lua`.

Anchor rule (editor-migration law): keep the **nvim** muscle memory (`space …`,
`ctrl-hjkl`); relocate Zed defaults freely.

## Done (verified equivalents)

| nvim | Zed | Action |
|---|---|---|
| `ctrl-h/j/k/l` (normal + terminal) | `ctrl-h/j/k/l` | `workspace::ActivatePaneInDirection` (directional dock nav) |
| `jk` (insert) → esc | `j k` | `vim::NormalBefore` |
| `S-h` / `S-l` | `H` / `L` | `pane::ActivatePrevious/NextItem` |
| `<leader>fs` save | `space f s` | `workspace::Save` |
| `<leader>q` close/quit | `space q` | `pane::CloseActiveItem` |
| `<leader>sf` find files | `space s f` | `file_finder::Toggle` |
| `<leader>sg` live grep | `space s g` | `pane::DeploySearch` |
| `<leader>;` toggle term | `space ;` | `terminal_panel::ToggleFocus` |
| `<leader>lg` lazygit | `space l g` | task `lazygit` |
| `<leader>as` send selection | `cmd-i` (visual) | `assistant::QuoteSelection` |
| `<leader>ac` / `<leader>af` AI toggle/focus | `cmd-i` | `agent::ToggleFocus` |
| `<leader>at` task workflow | `space a t` | `git::Worktree` (see D3 below) |
| `<leader>on` obsidian new | `space o n` | task `obsidian-new` |
| `<leader>od` obsidian daily | `space o d` | task `obsidian-daily` |
| `<leader>os` obsidian search | `space o s` | task `obsidian-search` |

Zed-native extras already in place: `space r` rename, `g h`/`g l` back/forward,
`z a` fold, `[ d`/`] d` diagnostics, `space tab` tab switcher, `space e` tab bar,
`t t`/`t f`/`t n`/`t s` tasks, `space g b` git branch, GitPanel/ProjectPanel maps.

## D3 — worktree workflow mapping

- `utils/worktree.lua` (git worktree create/list/remove) → **`git::Worktree`**
  (bound to `space a t`; default also `cmd-ctrl-w`). New trees land in
  `worktree_directory` (Zed default `../worktrees`; set in `settings.json` if you
  want a different trees folder).
- AI-in-worktree (old workflow's sidekick step) → **Zed agent worktrees**: open
  `git::Worktree`, then `cmd-i` runs the agent panel inside that tree. No glue code.
- **Dropped (tmux-coupled, intentionally not ported):** `ai-tools/task-workflow`
  (input→worktree→tmux window→nvim→sidekick) and `tmux_spec`. After cutover their
  tmux orchestration has no role.
- `project-last-file` → nice-to-have; Zed restores last session per project, so
  effectively covered. Not bound.

## Open parity items (opt-in — propose, not yet bound)

Bindings below are candidates; left unbound to avoid clobbering vim motions or
binding to uncertain actions. Add when the muscle memory bites.

| nvim | Proposed Zed | Why deferred / priority |
|---|---|---|
| `;` → `:` (command mode) | `";": ["workspace::SendKeystrokes", ":"]` | Overrides vim `;` (repeat f/t). Confirm feel before binding. **Med** |
| `<leader>ac` / `<leader>af` | `space a c` / `space a f` → `agent::ToggleFocus` | Already on `cmd-i`; add space-cluster only if reaching for it. **Low** |
| `<leader>ar` resume / `<leader>aC` continue | — | Zed agent thread history is a panel UI; no clean single action. **Low** |
| `<leader>am` select AI tool | — | Zed model picker is panel UI. **Low** |
| `<leader>ab` add buffer to AI | — | Zed agent add-context is UI-driven. **Low** |
| `<leader>aR` review branch | — | No Zed core equivalent; use agent panel / `gh`. **Low** |
| `<leader>oo/olf/olb/or/ot` obsidian | — | Zed isn't an Obsidian client; edit notes in Obsidian. **Low** |
| `<leader>p*` PR review (8 maps) | — | Bespoke nvim plugin; use `gh` CLI / agent / GitHub web. **Low** |

Last reviewed: 2026-06-04 (Zed 1.4.4).
