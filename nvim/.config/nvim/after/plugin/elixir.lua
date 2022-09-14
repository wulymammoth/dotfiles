local elixir = require("elixir")

elixir.setup {
  elixir.settings {
    dialyzerEnabled = true,
    fetchDeps = true,
    enableTestLenses = false,
    suggestSpecs = false,
  },
}
