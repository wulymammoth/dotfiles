return {
  {
    "olimorris/codecompanion.nvim",
    version = "^18.0.0",
    cmd = { "CodeCompanionChat", "CodeCompanionActions" },
    keys = {
      { "<leader>aa", "<cmd>CodeCompanionActions<cr>", mode = { "n", "v" }, desc = "CodeCompanion Actions" },
      { "<leader>ac", "<cmd>CodeCompanionChat Toggle<cr>", mode = { "n", "v" }, desc = "CodeCompanion Chat Toggle" },
    },
    opts = {
      log_level = "DEBUG",
      adapters = {
        codex = function()
          return require("codecompanion.adapters").extend("codex", {
            defaults = {
              auth_method = "chatgpt",
            },
          })
        end,
      },
      strategies = {
        chat = {
          adapter = "codex",
        },
      },
    },
    config = function(_, opts)
      require("codecompanion").setup(opts)
    end,
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-treesitter/nvim-treesitter",
    },
  },
}
