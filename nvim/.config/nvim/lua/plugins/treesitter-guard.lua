return {
  {
    "nvim-treesitter/nvim-treesitter",
    opts = function(_, opts)
      opts = opts or {}

      -- Hard guard: avoid loading known-problematic markdown parser binaries.
      opts.ignore_install = opts.ignore_install or {}
      for _, lang in ipairs({ "markdown", "markdown_inline" }) do
        if not vim.tbl_contains(opts.ignore_install, lang) then
          table.insert(opts.ignore_install, lang)
        end
      end

      if type(opts.ensure_installed) == "table" then
        opts.ensure_installed = vim.tbl_filter(function(lang)
          return lang ~= "markdown" and lang ~= "markdown_inline"
        end, opts.ensure_installed)
      end

      opts.highlight = opts.highlight or {}
      opts.highlight.disable = opts.highlight.disable or {}
      if type(opts.highlight.disable) == "table" then
        for _, lang in ipairs({ "markdown", "markdown_inline" }) do
          if not vim.tbl_contains(opts.highlight.disable, lang) then
            table.insert(opts.highlight.disable, lang)
          end
        end
      end
    end,
  },
}
