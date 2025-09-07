-- Inline completion configuration for Neovim 0.12.0+
-- Based on https://github.com/neovim/neovim/pull/33972
-- Available API: enable, get, is_enabled, select
return {
  {
    "neovim/nvim-lspconfig",
    opts = function(_, opts)
      -- Enable inline completion globally when LSP supports it
      vim.api.nvim_create_autocmd("LspAttach", {
        callback = function(args)
          local client = vim.lsp.get_client_by_id(args.data.client_id)
          if client and client.supports_method("textDocument/inlineCompletion") then
            vim.lsp.inline_completion.enable()
          end
        end,
      })

      return opts
    end,
    keys = {
      -- Accept/select inline completion
      {
        "<C-y>",
        function()
          local completion = vim.lsp.inline_completion.get()
          if completion then
            vim.lsp.inline_completion.select()
            return
          end
          return "<C-y>"
        end,
        expr = true,
        mode = "i",
        desc = "Accept inline completion",
      },
      -- Get current inline completion (for debugging)
      {
        "<C-x><C-i>",
        function()
          local completion = vim.lsp.inline_completion.get()
          if completion then
            print("Inline completion available:", vim.inspect(completion))
          else
            print("No inline completion available")
          end
        end,
        mode = "i",
        desc = "Show inline completion info",
      },
    },
  },
}