local wezterm = require 'wezterm';

return {
  color_scheme = "iceberg-dark",

  font = wezterm.font("Hack Nerd Font Mono"),
  font_size = 14.5,

  keys = {
    -- Give me my Vim binding
    { key = '^', mods = 'SHIFT|CTRL', action = wezterm.action.DisableDefaultAssignment },

    -- Give me my undo
    { key = "_", mods = "SHIFT|CTRL", action = wezterm.action.DisableDefaultAssignment },

    -- Make Option-Left equivalent to Alt-b which many line editors interpret as backward-word
    { key="b", mods="OPT", action=wezterm.action{ SendString="\x1bb" } },

    -- delete forward
    { key="d", mods="OPT", action=wezterm.action{ SendString="\x1bd" } },

    -- Make Option-Right equivalent to Alt-f; forward-word
    { key="f", mods="OPT", action=wezterm.action{ SendString="\x1bf" } },
  },

  window_decorations = "NONE"
}
