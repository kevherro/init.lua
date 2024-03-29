-- Reference:
-- https://github.com/VonHeikemen/nvim-starter/blob/04-lsp-installer/init.lua
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
  --{'folke/tokyonight.nvim'},
  --{'joshdick/onedark.vim'},
  --{'tanvirtin/monokai.nvim'},
  --{'lunarvim/darkplus.nvim'},
  --{'kyazdani42/nvim-web-devicons'},
  { "nvim-lualine/lualine.nvim" },
  --{'akinsho/bufferline.nvim'},
  { "gruvbox-community/gruvbox" },
  { "lukas-reineke/indent-blankline.nvim", version = "3.x" },

  -- File explorer
  --{'kyazdani42/nvim-tree.lua'},

  -- Fuzzy finder
  { "nvim-telescope/telescope.nvim", tag = "0.1.6" },
  { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },

  -- Git
  { "lewis6991/gitsigns.nvim" },
  { "tpope/vim-fugitive" },

  -- Code manipulation
  { "nvim-treesitter/nvim-treesitter" },
  { "nvim-treesitter/nvim-treesitter-textobjects" },
  --{'numToStr/Comment.nvim'},
  --{'tpope/vim-surround'},
  --{'wellle/targets.vim'},
  --{'tpope/vim-repeat'},

  -- Utilities
  --{'moll/vim-bbye'},
  { "nvim-lua/plenary.nvim" },
  --{'akinsho/toggleterm.nvim'},

  -- LSP support
  { "neovim/nvim-lspconfig" },
  { "williamboman/mason.nvim" },
  { "williamboman/mason-lspconfig.nvim" },

  -- Autocomplete
  { "hrsh7th/nvim-cmp" },
  { "hrsh7th/cmp-buffer" },
  { "hrsh7th/cmp-path" },
  { "saadparwaiz1/cmp_luasnip" },
  { "hrsh7th/cmp-nvim-lsp" },

  -- Snippets
  { "L3MON4D3/LuaSnip" },
  { "rafamadriz/friendly-snippets" },
})

-- PLUGIN CONFIGURATION ========================================================

-- Colorscheme -----------------------------------------------------------------
vim.opt.termguicolors = true
vim.cmd.colorscheme("gruvbox")

-- lualine.nvim (statusline) ---------------------------------------------------
vim.opt.showmode = false

-- See :help lualine.txt
require("lualine").setup({
  options = {
    theme = "gruvbox",
    icons_enabled = false,
    component_separators = ":",
    section_separators = "",
    disabled_filetypes = {
      statusline = { "NvimTree" },
    },
  },
})

-- Treesitter ------------------------------------------------------------------
require("nvim-treesitter.configs").setup({
  sync_install = false,
  auto_install = false,
  highlight = {
    enable = true,
    additional_vim_regex_highlighting = false,
  },
  -- :help nvim-treesitter-textobjects-modules
  textobjects = {
    select = {
      enable = true,
      lookahead = true,
      keymaps = {
        ["af"] = "@function.outer",
        ["if"] = "@function.inner",
        ["ac"] = "@class.outer",
        ["ic"] = "@class.inner",
      },
    },
  },
  ensure_installed = {
    "bash",
    "go",
    "json",
    "lua",
    "rust",
    "swift",
    "vim",
    "vimdoc",
  },
})

-- Indent-blankline ------------------------------------------------------------
require("ibl").setup({
  enabled = true,
  scope = {
    enabled = false,
  },
})

-- Telescope -------------------------------------------------------------------
local builtin = require("telescope.builtin")
vim.keymap.set("n", "<leader>pf", builtin.find_files, {})
vim.keymap.set("n", "<C-p>", builtin.git_files, {})
vim.keymap.set("n", "<leader>ps", function()
  builtin.grep_string({ search = vim.fn.input("Grep > ") })
end)
vim.keymap.set("n", "<leader>vh", builtin.help_tags, {})

require("telescope").load_extension("fzf")

-- Luasnip (snippet engine) ----------------------------------------------------
require("luasnip.loaders.from_vscode").lazy_load()

-- nvim-cmp (autocomplete) -----------------------------------------------------
vim.opt.completeopt = { "menu", "menuone", "noselect" }

local cmp = require("cmp")
local luasnip = require("luasnip")

local select_opts = { behavior = cmp.SelectBehavior.Select }

-- :help cmp-config
cmp.setup({
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },
  sources = {
    { name = "path" },
    { name = "nvim_lsp" },
    { name = "buffer", keyword_length = 3 },
    { name = "luasnip", keyword_length = 2 },
  },
  window = {
    --completion = cmp.config.window.bordered(),
    --documentation = cmp.config.window.bordered(),
  },
  formatting = {
    fields = { "menu", "abbr", "kind" },
    format = function(entry, item)
      local menu_icon = {
        nvim_lsp = "λ",
        luasnip = "⋗",
        buffer = "Ω",
        path = " ",
      }
      item.menu = menu_icon[entry.source.name]
      return item
    end,
  },
  -- :help cmp-mapping
  mapping = {
    ["<Up>"] = cmp.mapping.select_prev_item(select_opts),
  },
})

-- LSP Servers -----------------------------------------------------------------
require("mason").setup({
  ui = { border = "rounded" },
})

local lspconfig = require("lspconfig")
local lsp_capabilities = require("cmp_nvim_lsp").default_capabilities()

-- :help mason-lspconfig-settings
require("mason-lspconfig").setup({
  ensure_installed = {
    "gopls",
    "lua_ls",
    "rust_analyzer",
  },
  -- :help mason-lspconfig.setup_handlers()
  handlers = {
    function(server)
      -- :help lspconfig-setup
      lspconfig[server].setup({
        capabilities = lsp_capabilities,
      })
    end,
    ["gopls"] = function()
      lspconfig.gopls.setup({
        capabilities = lsp_capabilities,
        settings = {
          completions = {
            completeFunctionCalls = true,
          },
        },
      })
    end,
    ["lua_ls"] = function()
      lspconfig.gopls.setup({
        capabilities = lsp_capabilities,
        settings = {
          completions = {
            completeFunctionCalls = true,
          },
          Lua = {
            diagnostics = {
              globals = { "vim" }, -- Fix undefined global 'vim'
            },
          },
        },
      })
    end,
    ["rust_analyzer"] = function()
      lspconfig.rust_analyzer.setup({
        capabilities = lsp_capabilities,
        settings = {
          completions = {
            completeFunctionCalls = true,
          },
        },
      })
    end,
  },
})
