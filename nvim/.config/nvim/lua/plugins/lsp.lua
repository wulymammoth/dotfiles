local function get_python_path()
  local home = os.getenv("HOME")
  local venv_path = os.getenv("VIRTUAL_ENV")

  if venv_path then
    -- If a virtual environment is activated, return the path to the Python executable
    return venv_path .. "/bin/python"
  else
    -- Otherwise, fallback to system Python or another preferred interpreter
    return home .. "/.asdf/shims/python"
  end
end

return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      opts.diagnostics = vim.tbl_deep_extend("force", opts.diagnostics or {}, {
        underline = false,
        update_in_insert = false,
        virtual_text = {
          highlight = "Comment",
          prefix = "icons",
          severity = vim.diagnostic.severity.ERROR,
          source = "if_many",
          spacing = 5,
          underline = false,
        },
      })

      opts.inlay_hints = vim.tbl_deep_extend("force", opts.inlay_hints or {}, {
        enabled = true,
      })

      opts.servers = opts.servers or {}
      opts.servers["*"] = vim.tbl_deep_extend("force", opts.servers["*"] or {}, {})
      opts.servers["*"].keys = opts.servers["*"].keys or {}
      vim.list_extend(opts.servers["*"].keys, {
        { "gd", vim.lsp.buf.definition, desc = "Goto Definition", has = "definition" },
        { "gD", vim.lsp.buf.declaration, desc = "Goto Declaration" },
        { "gr", vim.lsp.buf.references, desc = "References", nowait = true },
        { "gi", vim.lsp.buf.implementation, desc = "Goto Implementation" },
        { "K", vim.lsp.buf.hover, desc = "Hover", has = "hover" },
        { "<C-k>", vim.lsp.buf.signature_help, mode = "n", desc = "Signature Help", has = "signatureHelp" },
        { "<leader>rn", vim.lsp.buf.rename, desc = "Rename", has = "rename" },
        { "<leader>ca", vim.lsp.buf.code_action, mode = { "n", "x" }, desc = "Code Action", has = "codeAction" },
      })

      opts.servers.basedpyright = vim.tbl_deep_extend("force", opts.servers.basedpyright or {}, {
        flags = {
          debounce_text_changes = 150,
          allow_incremental_sync = false,
        },
        settings = {
          basedpyright = {
            analysis = {
              autoSearchPaths = true,
              diagnosticMode = "workspace",
            },
          },
          python = {
            pythonPath = get_python_path(),
          },
        },
      })

      opts.servers.lua_ls = vim.tbl_deep_extend("force", opts.servers.lua_ls or {}, {
        settings = {
          Lua = {
            diagnostics = {
              globals = { "vim" },
            },
            workspace = {
              checkThirdParty = false,
            },
            telemetry = {
              enable = false,
            },
          },
        },
      })

      opts.servers.expert = vim.tbl_deep_extend("force", opts.servers.expert or {}, {
        mason = false,
        cmd = { vim.fn.expand("~/.local/share/nvim/mason/bin/expert") },
        filetypes = { "elixir", "eelixir", "heex" },
        root_markers = { "mix.exs", ".git" },
      })

      if opts.servers.tsserver then
        opts.servers.tsserver.enabled = false
      end
      if opts.servers.ts_ls then
        opts.servers.ts_ls.enabled = false
      end
    end,
  },
}
