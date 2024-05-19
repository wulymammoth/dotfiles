local null_ls = require("null-ls")
local augroup = vim.api.nvim_create_augroup("LspFormatting", {})

null_ls.setup({
  -- NOTE: whenever any of these dependencies don't work, ensure that Mason has them installed
  debug = false,

  sources = {
    -- language agnostic
    null_ls.builtins.code_actions.gitsigns,
    null_ls.builtins.completion.spell,
    null_ls.builtins.diagnostics.hadolint,
    null_ls.builtins.diagnostics.todo_comments,
    null_ls.builtins.diagnostics.trail_space,
    null_ls.builtins.diagnostics.sqlfluff.with({
      extra_args = { "--dialect", "postgres" },
    }),

    -- elixir
    null_ls.builtins.diagnostics.credo,
    null_ls.builtins.formatting.mix,

    -- lua
    null_ls.builtins.completion.luasnip,
    null_ls.builtins.diagnostics.luacheck,

    -- make
    null_ls.builtins.diagnostics.checkmake,

    -- python
    null_ls.builtins.diagnostics.ruff,

    -- null_ls.builtins.formatting.autoflake,
    -- null_ls.builtins.formatting.autopep8, -- instead of yapf
    -- null_ls.builtins.formatting.black,
    -- null_ls.builtins.formatting.isort,
    -- null_ls.builtins.formatting.reorder_python_imports, -- borking ordering (use isort)

    -- shell
    null_ls.builtins.code_actions.shellcheck,
  },

  on_attach = function(client, bufnr)
    bufnr = bufnr or vim.api.nvim_get_current_buf()
    local timeout = 2700

    if client.supports_method("textDocument/formatting") then
      vim.api.nvim_clear_autocmds({ group = augroup, buffer = bufnr })
      vim.api.nvim_create_autocmd("BufWritePost", {
        group = augroup,

        buffer = bufnr,

        callback = function()
          vim.lsp.buf.format({
            bufnr = bufnr,

            filter = function(client)
              return client.name == "null-ls"
            end,

            timeout = timeout,
            timeout_ms = timeout,
          })
        end,
      })
    end
  end,
})
