return {
  "nvim-treesitter/nvim-treesitter-refactor",
  dependencies = { "nvim-treesitter/nvim-treesitter" },

  config = function()
    require("nvim-treesitter.configs").setup({
      refactor = {
        highlight_current_scope = { enable = false },

        highlight_definitions = {
          enable = true,
          -- Set to false if you have an `updatetime` of ~100.
          clear_on_cursor_move = true,
        },

        smart_rename = {
          enable = true,
          -- Assign keymaps to false to disable them, e.g. `smart_rename = false`.
          keymaps = {
            smart_rename = "grr",
          },
        },
      },
    })
  end,
}
