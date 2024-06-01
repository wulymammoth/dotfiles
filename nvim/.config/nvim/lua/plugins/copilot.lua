return {
  "zbirenbaum/copilot.lua",
  lazy = true,
  config = function()
    require("copilot").setup({
      suggestion = { enable = true },
      panel = { enable = false },
    })
  end,
}
