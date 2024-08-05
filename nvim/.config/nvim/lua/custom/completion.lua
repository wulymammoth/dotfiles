require("lspkind").init()

local cmp = require("cmp")

cmp.setup({
  sources = {
    { name = "copilot" },
    { name = "luasnip" },
    { name = "nvim_lsp" },
  },

  mapping = {
    ["<C-e>"] = cmp.mapping.abort(),
    ["<C-n>"] = cmp.mapping.select_next_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-p>"] = cmp.mapping.select_prev_item({ behavior = cmp.SelectBehavior.Insert }),
    ["<C-y>"] = cmp.mapping(
      cmp.mapping.confirm({
        behavior = cmp.ConfirmBehavior.Insert,
        select = true,
      }),
      { "i", "c" }
    ),
  },
  --
  -- Enable luasnip to handle snippet expansion for nvim-cmp
  snippet = {
    expand = function(args)
      require("luasnip").lsp_expand(args.body)
    end,
  },

  window = {
    completion = cmp.config.window.bordered(),
    documentation = cmp.config.window.bordered(),
  },
})

local ls = require("luasnip")

ls.config.set_config({
  history = false,
  updateevents = "TextChanged,TextChangedI",
})

-- load my custom snippets (if any)
for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/custom/snippets/*.lua", true)) do
  loadfile(ft_path)()
end

-- luasnip jump to next parameter (in snippet)
vim.keymap.set({ "i", "s" }, "<C-,>", function()
  if ls.expand_or_jumpable() then
    ls.expand_or_jump()
  end
end, { silent = true })

vim.keymap.set({ "i", "s" }, "<C-m>", function()
  if ls.jumpable(-1) then
    ls.jump(-1)
  end
end, { silent = true })

-- rafamadriz/friendly-snippets
require("luasnip.loaders.from_vscode").lazy_load()

-- Set up lspconfig.
local capabilities = require("cmp_nvim_lsp").default_capabilities()
language_servers = {
  "dockerls",
  "eslint",
  "jsonls",
  "lexical", -- Elixir
  "lua_ls",
  "marksman",
  "pyright",
  "ruff",
  "rust_analyzer",
  "solargraph",
  "tailwindcss",
  "taplo",
  "tsserver",
  "yamlls",
}

lsp_config = require("lspconfig")

for _, lsp in ipairs(language_servers) do
  lsp_config[lsp].setup({
    capabilities = capabilities,
  })
end
