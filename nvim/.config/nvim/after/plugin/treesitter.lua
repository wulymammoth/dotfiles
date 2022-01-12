require'nvim-treesitter.configs'.setup {
  -- One of "all", "maintained" (parsers with maintainers), or a list of languages
  -- ensure_installed = "maintained",

  highlight = {
    -- `false` will disable the whole extension
    enable = true,

    ensure_installed = { 'python', 'ruby', 'rust' },

    -- Setting this to true will run `:h syntax` and tree-sitter at the same time.
    -- Set this to `true` if you depend on 'syntax' being enabled (like for indentation).
    -- Using this option may slow down your editor, and you may see some duplicate highlights.
    -- Instead of true it can also be a list of languages
    additional_vim_regex_highlighting = false,
  },

  indent = { enable = false },

  refactor = {
    highlight_current_scope = { enable = true },
    highlight_definitions = { enable = true },
    smart_rename = { enable = true, keymaps = { smart_rename = "grr" },
    },
  },

  -- Install languages synchronously (only applied to `ensure_installed`)
  sync_install = false,
}
