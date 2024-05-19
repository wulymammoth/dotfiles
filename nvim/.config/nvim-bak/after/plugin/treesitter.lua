require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {
    "bash",
    "c",
    "clojure",
    "comment",
    "cpp",
    "css",
    "diff",
    "dockerfile",
    "dot",
    "elixir",
    "erlang",
    "git_rebase",
    "gitcommit",
    "gitignore",
    "go",
    "heex",
    "html",
    "http",
    "java",
    "javascript",
    "jq",
    "json",
    "kotlin",
    "make",
    "markdown",
    "markdown_inline",
    "proto",
    "python",
    "regex",
    "ruby",
    "sql",
    "swift",
    "toml",
    "typescript",
    "vim",
    "yaml",
  },

  ignore_install = { "phpdoc" },

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,

    -- this shit is painful when loading massive files
    disable = function(lang, bufnr) -- Disable in files with more than 5K
        return vim.api.nvim_buf_line_count(bufnr) > 1800
    end,
  },

  indent = {
    enable = true
  },

  refactor = {
    highlight_current_scope = { enable = false },
    highlight_definitions = { enable = true },
    smart_rename = {
      enable = true,
      keymaps = { smart_rename = "grr", },
    },
  },

  auto_install = true,

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,
}
