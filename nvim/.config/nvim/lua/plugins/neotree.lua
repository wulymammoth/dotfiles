return {
  "nvim-neo-tree/neo-tree.nvim",

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
