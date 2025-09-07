return {
  {
    "zbirenbaum/copilot.lua",
    opts = {
      suggestion = { enabled = true },
      panel = { enabled = false },
    },
    config = function()
      require("copilot").setup({
        suggestion = { enabled = true },
        panel = { enabled = false },
      })
      
      -- Enable native Vim inline completion for Copilot LLM-based suggestions
      -- Based on https://github.com/neovim/neovim/pull/33972
      if vim.lsp.inline_completion then
        vim.lsp.inline_completion.enable(true)
      end
      
      -- Keymaps for inline suggestions
      vim.keymap.set("i", "<Tab>", function()
        -- First check if native inline completion is available and has suggestions
        if vim.lsp.inline_completion and vim.lsp.inline_completion.get() then
          vim.lsp.inline_completion.accept()
          return
        end
        
        -- Fall back to Copilot suggestion API
        local copilot = require("copilot.suggestion")
        if copilot.is_visible() then
          copilot.accept()
        else
          return "<Tab>"
        end
      end, { expr = true, silent = true })
      
      vim.keymap.set("i", "<C-]>", function()
        if vim.lsp.inline_completion and vim.lsp.inline_completion.get() then
          vim.lsp.inline_completion.select()
        else
          require("copilot.suggestion").next()
        end
      end, { silent = true })
      
      vim.keymap.set("i", "<C-[>", function()
        require("copilot.suggestion").prev()
      end, { silent = true })
      
      vim.keymap.set("i", "<C-\\>", function()
        if vim.lsp.inline_completion and vim.lsp.inline_completion.get() then
          vim.lsp.inline_completion.hide()
        else
          require("copilot.suggestion").dismiss()
        end
      end, { silent = true })
    end,
  },
}