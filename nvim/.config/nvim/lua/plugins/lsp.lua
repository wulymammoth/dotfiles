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

      if opts.servers.ts_ls then
        opts.servers.ts_ls.enabled = false
      end
    end,
  },
}
