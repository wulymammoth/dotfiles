local wezterm = require 'wezterm';

return {
  color_scheme = "iceberg-dark",

  font = wezterm.font("Hack Nerd Font Mono", {
    weight="Medium",
  }),
  font_size = 14.75,

  front_end = "WebGpu",

  hide_tab_bar_if_only_one_tab = true,

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

  use_fancy_tab_bar = false,

  use_resize_increments = true,

  window_close_confirmation = 'AlwaysPrompt',
  window_decorations = "RESIZE",
}
