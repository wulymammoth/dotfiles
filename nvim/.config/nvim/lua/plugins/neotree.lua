return {
  "nvim-neo-tree/neo-tree.nvim",

  init = function()
    vim.g.neotree = {
      auto_close = true,
      auto_open = false,
      auto_update = true,
      update_to_buf_dir = true,
    }
  end,

  -- merged with the default configuration
  opts = {
    close_if_last_window = true,

    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
    },

    hijack_netrw_behavior = "disabled",
  },
}
