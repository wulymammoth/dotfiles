local ls = require 'luasnip'
local types = require 'luasnip.util.types'

ls.config.set_config {
  -- this tells LuaSnip to keep the last snippet around
  -- we can jump back even if we move outside the selection
  history = true,

  -- live updates as we type
  updateevents = "TextChanged,TextChangedI",

  -- AUTOSNIPPETS (TJ)
  -- enable_autosnippets = true,

  -- HIGHTLIGHTS (TJ)
  -- ext_opts = {
  --   [types.choiceNode] = {
  --     active = {
  --       virt_text = { { "<-", "Error" } },
  --     }
  --   }
  -- }
}
