return {
  "nvim-neo-tree/neo-tree.nvim",

  -- merged with the default configuration
  opts = {
    filesystem = {
      filtered_items = {
        hide_dotfiles = false,
        hide_gitignored = true,
      },
    },
  },
}
