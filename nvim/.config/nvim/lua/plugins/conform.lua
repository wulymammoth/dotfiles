return {
  "stevearc/conform.nvim",

  -- opts will be merged with the parent spec
  opts = {
    formatters_by_ft = {
      eelixir = { "mix" },
      elixir = { "mix" },
      heex = { "mix" },
      python = {
        "ruff_fix",
        "ruff_format",
        "ruff_organize_imports",
      },
      surface = { "mix" },
    },

    timeout_ms = 1000,
  },
}
