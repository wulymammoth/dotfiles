local cmp     = require('cmp')
local lspkind = require('lspkind')
local luasnip = require('luasnip')

local has_words_before = function()
  local line, col = unpack(vim.api.nvim_win_get_cursor(0))
  return col ~= 0 and vim.api.nvim_buf_get_lines(0, line - 1, line, true)[1]:sub(col, col):match("%s") == nil
end

cmp.setup {
  -- nvim-dap (nvim-cmp by defaults disables autocomplete for prompt buffers)
  enabled = function ()
    return vim.api.nvim_buf_get_option(0, "buftype") ~= "prompt"
      or require("cmp_dap").is_dap_buffer()
  end,

  formatting = {
    format = lspkind.cmp_format({
      menu = {
        buffer   = '[buf]',
        luasnip  = '[luasnip]',
        nvim_lsp = '[LSP]',
        path     = '[path]',
      },
      maxwidth = 50, -- prevent the popup from showing more than provided characters (e.g 50 will not show more than 50 characters)
      with_text = true,
    })
  },

  mapping = {
    ['<C-b>']     = cmp.mapping(cmp.mapping.scroll_docs(-4), { 'i', 'c' }),
    ['<C-f>']     = cmp.mapping(cmp.mapping.scroll_docs(4), { 'i', 'c' }),
    ['<C-Space>'] = cmp.mapping(cmp.mapping.complete(), { 'i', 'c' }),
    ['<C-e>']     = cmp.mapping({ i = cmp.mapping.abort(), c = cmp.mapping.close() }),
    ['<c-y>']     = cmp.mapping(
      cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Insert, select = true },
      { 'i', 'c' }
    ),
    ['<CR>'] = cmp.mapping.confirm({ select = true }), -- Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.

    -- luasnip
    ['<c-l>'] = cmp.mapping(function(fallback)
      if luasnip.choice_active() then
        luasnip.change_choice(1)
      end
    end),

    ['<c-j>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      elseif has_words_before() then
        cmp.complete()
      else
        fallback()
      end
    end, { "i", "s" }),

    ['<c-k>'] = cmp.mapping(function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end, { "i", "s" }),
  },

  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  sources = cmp.config.sources({
    -- { name = 'buffer', keyword_length = 3 },
    { name = 'nvim_lsp', keyword_length = 3 },
    -- { name = 'luasnip', keyword_length = 3 },
    -- { name = 'dap', keyword_length = 3 },
  })
}
