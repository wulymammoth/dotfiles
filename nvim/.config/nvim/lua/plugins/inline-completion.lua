-- Inline completion configuration for Neovim 0.12.0+.
-- On older Neovim versions, this file returns no plugin specs.
if vim.fn.has("nvim-0.12") == 0 then
  return {}
end

return {
  {
    "folke/snacks.nvim",
    init = function()
      local inline_completion = vim.lsp and vim.lsp.inline_completion
      if not inline_completion or type(inline_completion.enable) ~= "function" then
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
  },
}
