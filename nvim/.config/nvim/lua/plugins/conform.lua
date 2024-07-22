return {
  "stevearc/conform.nvim",

  -- opts will be merged with the parent spec
  opts = {
    formatters_by_ft = {
      eelixir = { "mix" },
      elixir = { "mix" },
      heex = { "mix" },
      -- NOTE: (BUG) python (ruff) manually configured 7/22/24 (for formatting to work)
      python = function(bufnr)
        if require("conform").get_formatter_info("ruff_format", bufnr).available then
          return { "ruff_format" }
        else
          return { "isort", "black" }
        end
      end,
      surface = { "mix" },
    },

    timeout_ms = 1000,
  },
}
