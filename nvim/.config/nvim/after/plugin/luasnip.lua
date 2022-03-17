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

-- item expansion or jump to next item/field in the snippet
-- *do this in INSERT or SELECT modes*
vim.keymap.set({ 'i', 's' }, '<c-k>', function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })
-- reverse-jump
vim.keymap.set({ 'i', 's' }, '<c-j>', function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })
-- cycle list of snippet options
vim.keymap.set({ 'i', 's' }, '<c-j>', function()
  if ls.choice_active() then
    ls.change_choice(1)
  end
end)
