local cmp     = require('cmp')
local lspkind = require('lspkind')

cmp.setup({
  formatting = {
    format = lspkind.cmp_format({
      menu = {
        buffer   = '[buf]',
        nvim_lsp = '[LSP]',
        path     = '[path]',
        luasnip  = '[luasnip]',
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
  },

  snippet = {
    expand = function(args)
      require('luasnip').lsp_expand(args.body)
    end,
  },

  sources = cmp.config.sources({
    { name = 'buffer', keyword_length = 1 },
    { name = 'luasnip' },
    { name = 'nvim_lsp' },
    { name = 'path' },
  })
})
