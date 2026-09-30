-- Run with: NVIM_LOG_FILE=/tmp/nvim-runtime.log nvim -l tests/nvim-runtime.lua
-- Uses installed plugins, but never installs, updates, or starts language servers.
local root = vim.fn.getcwd() .. "/nvim/.config/nvim"
vim.o.loadplugins = true
vim.opt.rtp:prepend(root)
vim.opt.rtp:prepend(vim.fn.stdpath("data") .. "/lazy/lazy.nvim")

local lazy = require("lazy")
local setup = lazy.setup
lazy.setup = function(opts)
  if vim.env.NVIM_AUDIT_LOCAL_PLUGINS == "1" then
    opts.root = vim.fn.stdpath("data") .. "/managed"
    opts.dev = { path = vim.fn.stdpath("data") .. "/lazy", patterns = { "" }, fallback = false }
  end
  opts.install = { missing = false }
  opts.checker = { enabled = false }
  opts.change_detection = { enabled = false }
  opts.readme = { enabled = false }
  -- Include the actual cache: stale package specs can revive removed extras.
  opts.pkg = {
    cache = vim.env.NVIM_RUNTIME_PKG_CACHE or vim.fn.expand("~/.local/state/nvim/lazy/pkg-cache.lua"),
  }
  opts.rocks = { enabled = false }
  setup(opts)
end
require("config.lazy")
lazy.setup = setup

local failures = {}
local function check(name, fn)
  local ok, err = pcall(fn)
  if ok then
    print("PASS: " .. name)
  else
    failures[#failures + 1] = name
    print("FAIL: " .. name .. ": " .. tostring(err))
  end
end

local lsp = LazyVim.opts("nvim-lspconfig")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/nvim-lspconfig")
vim.lsp.config("expert", lsp.servers.expert)
local expert = vim.lsp.config.expert

check("Expert uses stdio and is the only configured Elixir server", function()
  assert(vim.tbl_contains(expert.cmd, "--stdio"), "Expert command is missing --stdio")
  assert(lsp.servers.elixirls.enabled == false, "ElixirLS would also be enabled")
  assert(lsp.servers.expert.mason ~= false, "Expert installation is excluded from Mason")
  assert(vim.tbl_contains(expert.filetypes, "surface"), "Surface support was lost")
end)

check("Python does not force a startup interpreter or full-document sync", function()
  local python = lsp.servers.basedpyright
  assert(not python.settings.python or not python.settings.python.pythonPath, "Python interpreter is fixed at startup")
  assert(not python.flags or python.flags.allow_incremental_sync ~= false, "Incremental synchronization is disabled")
end)

check("TypeScript selects vtsls without enabling a second server", function()
  assert(lsp.servers.vtsls.enabled ~= false, "vtsls is disabled")
  assert(lsp.servers.ts_ls.enabled == false, "ts_ls would also be enabled")
end)

local formatting = LazyVim.opts("conform.nvim")
vim.opt.rtp:append(vim.fn.stdpath("data") .. "/lazy/conform.nvim")
require("conform").setup(formatting)
check("Conform allows cold Mix startup and organizes imports before formatting", function()
  assert(require("conform").default_format_opts.timeout_ms >= 3000, "The timeout is too short for cold Mix startup")
  local python = require("conform").formatters_by_ft.python
  assert(
    python[1] == "ruff_organize_imports" and python[2] == "ruff_format",
    "Imports must be organized before formatting"
  )
  assert(vim.tbl_contains(formatting.formatters_by_ft.lua, "stylua"), "Lua formatting was lost")
  assert(vim.tbl_contains(formatting.formatters_by_ft.typescript, "prettier"), "TypeScript formatting was lost")
end)

check("Unused debugger and test integrations are not active", function()
  assert(not LazyVim.has("nvim-dap"), "Unused DAP integration remains active")
  assert(not LazyVim.has("nvim-dap-python"), "Cached Python DAP package remains active")
  assert(not LazyVim.has("neotest"), "Unused Neotest integration remains active")
end)

check("Markdown preview retains a loopback server and the existing picker", function()
  assert(not LazyVim.has("markdown-preview.nvim"), "Obsolete browser preview remains active")
  require("lazy").load({ plugins = { "live-preview.nvim" } })
  local preview = require("livepreview.config").config
  assert(preview.address == "127.0.0.1", "Preview must bind to loopback")
  assert(preview.picker == "fzf-lua", "Preview should use the existing picker")
end)

if #failures > 0 then
  error(tostring(#failures) .. " Neovim runtime configuration checks failed")
end
