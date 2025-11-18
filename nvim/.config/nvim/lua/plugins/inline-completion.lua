-- Inline completion configuration for Neovim 0.12.0+
-- Based on https://github.com/neovim/neovim/pull/33972
-- Available API: enable, get, is_enabled, select
return {
  "neovim/nvim-lspconfig",
  enabled = require("lazyvim.util").has("nvim-0.12"),
  init = function()
    local inline_completion = vim.lsp and vim.lsp.inline_completion
    if not inline_completion or type(inline_completion.enable) ~= "function" then
      -- Older Neovim builds can be < 0.12 even if Lazy thinks otherwise; bail out gracefully.
      return
    end

    vim.api.nvim_create_autocmd("LspAttach", {
      group = vim.api.nvim_create_augroup("kickstart-lsp-attach-inline-completion", { clear = true }),
      callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if client and client.server_capabilities.inlineCompletionProvider then
          inline_completion.enable({
            debounce = 150,
            show_on_undo = false,
          })
        end
      end,
    })
  end,
}
