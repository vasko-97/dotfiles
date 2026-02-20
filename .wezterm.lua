local wezterm = require 'wezterm'
local act = wezterm.action

return {
  -- 1️⃣ Default to pwsh
  default_prog = { "pwsh.exe" },

  -- 2️⃣ Leader key for custom commands
  leader = { key = ";", mods = "CTRL", timeout_milliseconds = 1000 },

  keys = {
    -- 🪟 Splitting panes
    { key = "v", mods = "LEADER", action = act.SplitVertical { domain = "CurrentPaneDomain" } },
    { key = "h", mods = "LEADER", action = act.SplitHorizontal { domain = "CurrentPaneDomain" } },

    -- 🔁 Pane selection (pick a pane by label)
    { key = "p", mods = "LEADER", action = act.PaneSelect { mode = "Activate" } },
    -- 📦 Swap active with selected pane
    { key = "s", mods = "LEADER", action = act.PaneSelect { mode = "SwapWithActive" } },

    -- 🧭 Navigate without Alt
    { key = "h", mods = "CTRL", action = act.ActivatePaneDirection "Left" },
    { key = "l", mods = "CTRL", action = act.ActivatePaneDirection "Right" },
    { key = "k", mods = "CTRL", action = act.ActivatePaneDirection "Up" },
    { key = "j", mods = "CTRL", action = act.ActivatePaneDirection "Down" },

    -- 🔍 Zoom pane (fullscreen toggle)
    { key = "f", mods = "LEADER", action = act.TogglePaneZoomState },

    -- ❌ Close pane
    { key = "x", mods = "LEADER", action = act.CloseCurrentPane { confirm = false } },
  },
}
