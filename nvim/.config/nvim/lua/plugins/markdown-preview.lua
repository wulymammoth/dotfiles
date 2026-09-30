return {
  { "iamcco/markdown-preview.nvim", enabled = false },
  {
    "brianhuster/live-preview.nvim",
    cmd = "LivePreview",
    opts = {
      picker = "fzf-lua",
    },
    config = function(_, opts)
      require("livepreview.config").set(opts)
    end,
    keys = {
      {
        "<leader>cp",
        function()
          if require("livepreview").is_running() then
            vim.cmd("LivePreview close")
          else
            vim.cmd("LivePreview start")
          end
        end,
        ft = "markdown",
        desc = "Markdown Preview",
      },
    },
  },
}
