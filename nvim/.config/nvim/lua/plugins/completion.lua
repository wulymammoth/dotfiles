return {
  {
    "saghen/blink.cmp",
    lazy = false,
    dependencies = {
      "rafamadriz/friendly-snippets",
      {
        "giuxtaposition/blink-cmp-copilot",
        specs = {
          {
            "zbirenbaum/copilot.lua",
            opts = {
              suggestion = { enabled = false },
              panel = { enabled = false },
            },
          },
        },
      },
    },
    version = "*",
    opts = {
      keymap = {
        preset = "default",
        ["<C-e>"] = { "hide" },
        ["<C-n>"] = { "select_next", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback" },
        ["<C-y>"] = { "accept", "fallback" },
      },
      appearance = {
        use_nvim_cmp_as_default = true,
        nerd_font_variant = "mono",
      },
      sources = {
        default = { "lsp", "path", "snippets", "buffer", "copilot" },
        providers = {
          copilot = {
            name = "copilot",
            module = "blink-cmp-copilot",
            score_offset = 100,
            async = true,
          },
        },
      },
      completion = {
        accept = {
          auto_brackets = {
            enabled = true,
          },
        },
        menu = {
          border = "rounded",
          draw = {
            treesitter = { "lsp" },
          },
        },
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
          window = {
            border = "rounded",
          },
        },
        ghost_text = {
          enabled = true,
        },
      },
      snippets = {
        expand = function(snippet)
          require("luasnip").lsp_expand(snippet)
        end,
        active = function(filter)
          if filter and filter.direction then
            return require("luasnip").jumpable(filter.direction)
          end
          return require("luasnip").in_snippet()
        end,
        jump = function(direction)
          require("luasnip").jump(direction)
        end,
      },
    },
    opts_extend = { "sources.default" },
  },
  {
    "L3MON4D3/LuaSnip",
    build = "make install_jsregexp",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    config = function()
      local ls = require("luasnip")
      ls.config.set_config({
        history = false,
        updateevents = "TextChanged,TextChangedI",
      })
      
      -- Load friendly-snippets
      require("luasnip.loaders.from_vscode").lazy_load()
      
      -- Load custom snippets if any
      for _, ft_path in ipairs(vim.api.nvim_get_runtime_file("lua/custom/snippets/*.lua", true)) do
        loadfile(ft_path)()
      end
      
      -- Snippet navigation keymaps
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
    end,
  },
}
