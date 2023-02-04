local wezterm = require 'wezterm';

return {
  color_scheme = "iceberg-dark",
  font_size = 14.5,
  keys = {
    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    { key = "_", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },
    { key="b", mods="OPT", action=wezterm.action{ SendString="\x1bb" } },
    -- Make Option-Right equivalent to Alt-f; forward-word
    { key="f", mods="OPT", action=wezterm.action{ SendString="\x1bf" } },
    -- { key = 'Enter', mods = 'CTRL|OPT', action = wezterm.action.DisableDefaultAssignment },
  },
  window_decorations = "NONE"
}
