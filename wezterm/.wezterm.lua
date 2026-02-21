local wezterm = require 'wezterm'
local act = wezterm.action

local is_windows = wezterm.target_triple:find('windows') ~= nil

local config = {
	-- 2️⃣ Leader key for custom commands
	leader = { key = ';', mods = 'CTRL', timeout_milliseconds = 1000 },

	keys = {
		-- 🪟 Splitting panes
		{ key = 'v', mods = 'LEADER', action = act.SplitVertical   { domain = 'CurrentPaneDomain' } },
		{ key = 'h', mods = 'LEADER', action = act.SplitHorizontal { domain = 'CurrentPaneDomain' } },
		-- 🔁 Pane selection (pick a pane by label)
		{ key = 'p', mods = 'LEADER', action = act.PaneSelect { mode = 'Activate' } },
		-- 📦 Swap active with selected pane
		{ key = 's', mods = 'LEADER', action = act.PaneSelect { mode = 'SwapWithActive' } },
		-- 🧭 Navigate without Alt
		{ key = 'h', mods = 'CTRL', action = act.ActivatePaneDirection 'Left'  },
		{ key = 'l', mods = 'CTRL', action = act.ActivatePaneDirection 'Right' },
		{ key = 'k', mods = 'CTRL', action = act.ActivatePaneDirection 'Up'    },
		{ key = 'j', mods = 'CTRL', action = act.ActivatePaneDirection 'Down'  },
		-- 🔍 Zoom pane (fullscreen toggle)
		{ key = 'f', mods = 'LEADER', action = act.TogglePaneZoomState },
		-- ❌ Close pane
		{ key = 'x', mods = 'LEADER', action = act.CloseCurrentPane { confirm = false } },
		-- Change active pane size
		{
			key = 'h',
			mods = 'CTRL|SHIFT',
			action = wezterm.action.AdjustPaneSize { 'Left', 5 },
		},
		{
			key = 'j',
			mods = 'CTRL|SHIFT',
			action = wezterm.action.AdjustPaneSize { 'Down', 5 },
		},
		{
			key = 'k',
			mods = 'CTRL|SHIFT',
			action = wezterm.action.AdjustPaneSize { 'Up', 5 },
		},
		{
			key = 'l',
			mods = 'CTRL|SHIFT',
			action = wezterm.action.AdjustPaneSize { 'Right', 5 },
		},
	},
}

if is_windows then
	config.default_prog = { 'pwsh.exe' }
end

-- make inactive panes slightly less bright
config.inactive_pane_hsb = {
	brightness = 0.7,
}

config.colors = {
	-- A bluish background color. Provides some contrast between active and inactive panes.
	background = "#1a1a2e"
}

return config
