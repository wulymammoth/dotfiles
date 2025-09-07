return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = false }, -- Disable inline - use blink.cmp menu only
      panel = { enabled = false },
    },
    config = function()
      require("copilot").setup({
        suggestion = { enabled = false }, -- Disable inline - use blink.cmp menu only
        panel = { enabled = false },
      })
      
      -- Set global flag to enable ai_cmp mode (LazyVim pattern)
      vim.g.ai_cmp = true
    end,
  },
}