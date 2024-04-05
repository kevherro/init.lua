-- Reference:
-- https://github.com/VonHeikemen/nvim-starter/blob/04-lsp-installer/init.lua
--
-- Format with :make fmt
--
-- OPTIONS =====================================================================

vim.g.mapleader = " "

vim.g.netrw_browse_split = 0
vim.g.netrw_banner = 0
vim.g.netrw_winsize = 25

vim.opt.guicursor = ""
vim.opt.nu = true
vim.opt.relativenumber = true
vim.opt.tabstop = 4
vim.opt.softtabstop = 4
vim.opt.shiftwidth = 4
vim.opt.expandtab = true
vim.opt.smartindent = true
vim.opt.wrap = false
vim.opt.swapfile = false
vim.opt.backup = false
vim.opt.undodir = os.getenv("HOME") .. "/.vim/undodir"
vim.opt.undofile = true
vim.opt.hlsearch = false
vim.opt.incsearch = true
vim.opt.termguicolors = true
vim.opt.scrolloff = 8
vim.opt.signcolumn = "yes"
vim.opt.isfname:append("@-@")
vim.opt.updatetime = 50
vim.opt.colorcolumn = "80"

vim.api.nvim_create_user_command("W", "write", {})
vim.api.nvim_create_user_command("Q", "quit", {})

-- COMMANDS ====================================================================

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

autocmd("TextYankPost", {
  group = augroup("HighlightYank", {}),
  pattern = "*",
  callback = function()
    vim.highlight.on_yank({
      higroup = "IncSearch",
      timeout = 40,
    })
  end,
})

autocmd({ "BufWritePre" }, {
  group = augroup("Kevin", {}),
  pattern = "*",
  command = [[%s/\s\+$//e]],
})

-- PLUGINS =====================================================================

local lazy = {}

function lazy.install(path)
  if not vim.loop.fs_stat(path) then
    vim.fn.system({
      "git",
      "clone",
      "--filter=blob:none",
      "https://github.com/folke/lazy.nvim.git",
      "--branch=stable", -- latest stable release
      path,
    })
  end
end

function lazy.setup(plugins)
  if vim.g.plugins_ready then
    return
  end

  -- lazy.install(lazy.path) -- Comment out after lazy.nvim is installed

  vim.opt.rtp:prepend(lazy.path)

  require("lazy").setup(plugins, lazy.opts)

  vim.g.plugins_ready = true
end

lazy.path = vim.fn.stdpath("data") .. "/lazy/lazy.nvim"
lazy.opts = {}

lazy.setup({
  -- Theming
  {
    "nvim-lualine/lualine.nvim",
    event = "VimEnter",
    config = function()
      require("lualine").setup({
        options = {
          theme = "gruvbox",
          icons_enabled = false,
          component_separators = ",",
          section_separators = "",
          disabled_filetypes = {
            statusline = { "NvimTree" },
          },
        },
      })
    end,
  },

  { "gruvbox-community/gruvbox" },

  {
    "lukas-reineke/indent-blankline.nvim",
    version = "3.x",
    event = "VimEnter",
    config = function()
      require("ibl").setup({
        enabled = true,
        scope = {
          enabled = false,
        },
      })
    end,
  },

  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", tag = "0.1.6" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Git
  { "tpope/vim-fugitive" },

  -- Code manipulation
  {
    "nvim-treesitter/nvim-treesitter",
    event = "VimEnter",
    config = function()
      require("nvim-treesitter.configs").setup({
        sync_install = false,
        auto_install = false,
        highlight = {
          enable = true,
          additional_vim_regex_highlighting = false,
        },
        ensure_installed = {
          "go",
          "json",
          "lua",
          "python",
          "rust",
          "swift",
          "vim",
          "vimdoc",
        },
      })
    end,
  },

  -- Utilities
  { "nvim-lua/plenary.nvim" },

  -- LSP
  { "" },

  -- Copilot
  -- { "github/copilot.vim" },
  {
    "Exafunction/codeium.vim",
    cmd = "Codeium",
  },
})

-- PLUGIN CONFIGURATION ========================================================

vim.opt.termguicolors = true
vim.cmd.colorscheme("gruvbox")

vim.opt.showmode = false -- remove mode from statusline

local builtin = require("telescope.builtin")

vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})

vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)

require("telescope").load_extension("fzf")
