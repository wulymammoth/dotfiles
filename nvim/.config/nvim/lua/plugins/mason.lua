return {
  -- Mason for managing LSP servers, formatters, and linters
  {
    "williamboman/mason.nvim",
    cmd = "Mason",
    build = ":MasonUpdate",
    opts = {
      ui = {
        icons = {
          package_installed = "✓",
          package_pending = "➜",
          package_uninstalled = "✗"
        },
        border = "rounded",
      },
      install_root_dir = (vim and vim.fn and vim.fn.stdpath("data") .. "/mason") or nil,
    },
  },

  -- Mason integration with nvim-lspconfig
  {
    "williamboman/mason-lspconfig.nvim",
    event = { "BufReadPre", "BufNewFile" },
    dependencies = {
      "williamboman/mason.nvim",
      "neovim/nvim-lspconfig",
    },
    opts = {
      -- Automatically install LSP servers
      ensure_installed = {
        "basedpyright",      -- Python LSP
        "ts_ls",             -- TypeScript/JavaScript LSP  
        "eslint",            -- ESLint language server
        "lua_ls",            -- Lua LSP
        "jsonls",            -- JSON LSP
        "yamlls",            -- YAML LSP
      },
      automatic_installation = true,
    },
  },

  -- Mason integration with nvim-dap for debugging
  {
    "jay-babu/mason-nvim-dap.nvim",
    dependencies = {
      "williamboman/mason.nvim",
      "mfussenegger/nvim-dap",
    },
    opts = {
      ensure_installed = {
        "python",    -- Python debugger
        "node2",     -- Node.js debugger
      },
      automatic_installation = true,
    },
  },
}