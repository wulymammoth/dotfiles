return {
  "stevearc/conform.nvim",

  -- opts will be merged with the parent spec
  opts = {
    formatters_by_ft = {
      elixir = { "mix" },
      eelixir = { "mix" },
      heex = { "mix" },
      surface = { "mix" },
    },
  },
}
