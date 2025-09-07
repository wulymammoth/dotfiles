-- Inline completion configuration for Neovim 0.11.0+
-- Based on https://github.com/neovim/neovim/pull/33972
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Enable inline completion globally
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method("textDocument/inlineCompletion") then
            vim.lsp.inline_completion.enable(true, { bufnr = args.buf })
          end
        end,
      })

      return opts
    end,
    keys = {
      -- Accept inline completion
      {
        "<C-y>",
        function()
          if vim.lsp.inline_completion.accept() then
            return
          end
          return "<C-y>"
        end,
        expr = true,
        mode = "i",
        desc = "Accept inline completion",
      },
      -- Trigger inline completion manually
      {
        "<C-x><C-i>",
        function()
          vim.lsp.inline_completion.trigger()
        end,
        mode = "i",
        desc = "Trigger inline completion",
      },
      -- Navigate through inline completion suggestions
      {
        "<M-]>",
        function()
          vim.lsp.inline_completion.next()
        end,
        mode = "i",
        desc = "Next inline completion",
      },
      {
        "<M-[>",
        function()
          vim.lsp.inline_completion.prev()
        end,
        mode = "i",
        desc = "Previous inline completion",
      },
      -- Clear inline completion
      {
        "<C-e>",
        function()
          if vim.lsp.inline_completion.clear() then
            return
          end
          return "<C-e>"
        end,
        expr = true,
        mode = "i",
        desc = "Clear inline completion",
      },
    },
  },
}