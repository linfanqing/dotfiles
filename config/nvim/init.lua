-- ==========================================================================
--  Globals & Options
-- ==========================================================================
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

local opt = vim.opt
local map = vim.keymap.set
local fn  = vim.fn
local api = vim.api

-- Options
opt.number         = true
opt.tabstop        = 4
opt.shiftwidth     = 4
opt.expandtab      = true
opt.smartindent    = true
opt.ignorecase     = true
opt.smartcase      = true
opt.termguicolors  = true
opt.scrolloff      = 8
opt.updatetime     = 250
opt.wrap           = false
opt.swapfile       = false
opt.laststatus     = 3
opt.cursorline     = true

-- General Keymaps
map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })
map("n", "<leader>x", "<cmd>bd<CR>", { desc = "Unload buffer" })

-- Search
map("n", "<Esc>", "<cmd>nohlsearch<cr>", { desc = "Clear search highlights" })

-- Window Navigation
map("n", "<leader>hw", "<C-w>h", { desc = "Window Left" })
map("n", "<leader>jw", "<C-w>j", { desc = "Window Down" })
map("n", "<leader>kw", "<C-w>k", { desc = "Window Up" })
map("n", "<leader>lw", "<C-w>l", { desc = "Window Right" })

-- Build/Make
map("n", "<leader>m", "<cmd>wa<CR><cmd>make<CR><CR><cmd>cw<CR>", { desc = "Save & Make" })

-- UI Toggles
map("n", "<C-l>", "<cmd>set nu!<CR>", { desc = "Toggle line numbers" })

-- Diffing
map("n", "<leader>dt", "<cmd>diffthis<CR>", { desc = "Enable diff mode" })
map("n", "<leader>do", "<cmd>diffoff<CR>", { desc = "Disable diff mode" })
map("n", "<leader>bd", "<cmd>set scb!<CR>", { desc = "Toggle scroll sync" }) -- scb = scrollbind

-- Quickfix Navigation
map("n", "]e", "<cmd>cn<CR>", { desc = "Next Quickfix error" })
map("n", "[e", "<cmd>cp<CR>", { desc = "Prev Quickfix error" })

-- Abbreviations
vim.cmd.iabbrev("10-", "----------")
vim.cmd.iabbrev("80-", "--------------------------------------------------------------------------------")
vim.cmd.iabbrev("80=", "================================================================================")

-- Highlight on yank
local yank_group = api.nvim_create_augroup('YankHighlight', { clear = true })
api.nvim_create_autocmd('TextYankPost', {
  group = yank_group,
  callback = function() vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' }) end
})

-- ==========================================================================
--  Lazy.nvim Bootstrap
-- ==========================================================================
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git", "clone", "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git", "--branch=stable", lazypath
  })
end
opt.rtp:prepend(lazypath)

-- ==========================================================================
--  Plugin Specs
-- ==========================================================================
require("lazy").setup({

  -- 1. FSwitch (Vimscript plugin)
  {
    'derekwyatt/vim-fswitch',
    keys = {
      { '<Leader>of', '<cmd>FSHere<cr>', silent = true },
      { '<Leader>ol', '<cmd>FSRight<cr>', silent = true },
      { '<Leader>oL', '<cmd>FSSplitRight<cr>', silent = true },
    },
    config = function()
      -- Helper function for fswitch
      local function set_fswitch(pattern, cmd)
        api.nvim_create_autocmd('Filetype', { pattern = pattern, command = cmd })
      end
      set_fswitch({'*.cpp'}, "let b:fswitchdst = 'hpp,h'")
      set_fswitch({'*.hpp'}, "let b:fswitchdst = 'cpp,cu'")
      set_fswitch({'*.cuh'}, "let b:fswitchdst = 'cu' | let b:fswitchlocs = 'reg:/include/src/'")
      set_fswitch({'*.cu'},  "let b:fswitchdst = 'cuh,hpp' | let b:fswitchlocs = 'reg:/src/include/'")
      set_fswitch({'*.h'},   "let b:fswitchdst = 'cpp,c' | let b:fswitchlocs = 'reg:/include/src/'")
    end
  },

  -- 2. Theme (Catppuccin)
  {
    "catppuccin/nvim",
    name = "catppuccin",
    priority = 1000,
    opts = {
      flavour = "frappe",
      background = { light = "latte", dark = "mocha" },
      transparent_background = true,
      show_end_of_buffer = false,
      term_colors = false,
      dim_inactive = { enabled = false },
      styles = {
        comments = { "italic" },
        conditionals = { "italic" },
      },
      integrations = {
        cmp = true,
        gitsigns = true,
        nvimtree = true,
        treesitter = true,
        notify = false,
        mini = { enabled = true, indentscope_color = "" },
      },
    },
    config = function(_, opts)
      require("catppuccin").setup(opts)
      vim.cmd.colorscheme "catppuccin"
    end
  },

  -- 3. File Explorer
  {
    "nvim-tree/nvim-tree.lua",
    version = "*",
    lazy = false,
    -- Removed nvim-web-devicons dependency
    keys = {
      { "<leader>r", "<cmd>NvimTreeToggle<CR>", desc = "Toggle NvimTree" },
      { "<leader>fl", "<cmd>NvimTreeFindFile<CR>", desc = "Find file in NvimTree" },
    },
    opts = {
      disable_netrw = true,
      hijack_netrw = true,
      view = {
        width = 32,
        side = "left",
      },
      filters = {
        dotfiles = true,
        custom = { "__pycache__" },
      },
      git = {
        enable = true,
        ignore = false,
      },
      -- Force ASCII renderer
      renderer = {
        group_empty = true,
        icons = {
          web_devicons = {
             file = { enable = false, color = false },
             folder = { enable = false, color = false },
          },
          show = {
            git = true,
            folder = true,
            file = false,
            folder_arrow = true,
          },
          glyphs = {
            default = "",
            symlink = "",
            bookmark = "#",
            modified = "*",
            folder = {
              arrow_closed = "+",
              arrow_open = "-",
              default = "[D]",
              open = "[O]",
              empty = "[ ]",
              empty_open = "[ ]",
              symlink = "->",
              symlink_open = "->",
            },
            git = {
              unstaged = "U",
              staged = "S",
              unmerged = "M",
              renamed = "R",
              untracked = "?",
              deleted = "D",
              ignored = "!",
            },
          },
        },
      },
    },
  },

  -- 4. NerdCommenter
  {
    'scrooloose/nerdcommenter',
    keys = {
      { '<leader>c', '<plug>NERDCommenterToggle', mode = { 'n', 'v' } },
    },
  },

  -- 5. Ack
  {
    'mileszs/ack.vim',
    cmd = "Ack",
    keys = {
      { '<leader>s', ':Ack!<CR>' },
    },
    init = function()
      vim.cmd.cnoreabbrev('S', 'Ack')
    end
  },

  -- 6. Git Signs
  {
    'lewis6991/gitsigns.nvim',
    event = { "BufReadPre", "BufNewFile" },
    dependencies = { 'nvim-lua/plenary.nvim', 'kyazdani42/nvim-web-devicons' },
    opts = {
      on_attach = function(bufnr)
        local gs = package.loaded.gitsigns
        local function map(mode, l, r, opts)
          opts = opts or {}
          opts.buffer = bufnr
          vim.keymap.set(mode, l, r, opts)
        end

        -- Navigation
        map('n', ']c', function()
          if vim.wo.diff then return ']c' end
          vim.schedule(function() gs.next_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        map('n', '[c', function()
          if vim.wo.diff then return '[c' end
          vim.schedule(function() gs.prev_hunk() end)
          return '<Ignore>'
        end, {expr=true})

        -- Actions
        map('n', '<leader>hs', gs.stage_hunk)
        map('n', '<leader>hr', gs.reset_hunk)
        map('v', '<leader>hs', function() gs.stage_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        map('v', '<leader>hr', function() gs.reset_hunk {vim.fn.line('.'), vim.fn.line('v')} end)
        map('n', '<leader>hS', gs.stage_buffer)
        map('n', '<leader>hu', gs.undo_stage_hunk)
        map('n', '<leader>hR', gs.reset_buffer)
        map('n', '<leader>hp', gs.preview_hunk)
        map('n', '<leader>hb', function() gs.blame_line{full=true} end)
        map('n', '<leader>tb', gs.toggle_current_line_blame)
        map('n', '<leader>hd', gs.diffthis)
        map('n', '<leader>hD', function() gs.diffthis('~') end)
        map('n', '<leader>td', gs.toggle_deleted)
        map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
      end
    }
  },

  -- 7. Fugitive
  { 'tpope/vim-fugitive', cmd = "Git" },

  -- 8. Autocomplete (CMP)
  {
    'hrsh7th/nvim-cmp',
    event = 'InsertEnter',
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'saadparwaiz1/cmp_luasnip',
    },
    config = function()
      local cmp = require('cmp')
      local luasnip = require('luasnip')
      cmp.setup({
        snippet = { expand = function(args) luasnip.lsp_expand(args.body) end },
        completion = { keyword_length = 2 },
        mapping = {
          ['<C-n>'] = cmp.mapping.select_next_item(),
          ['<C-p>'] = cmp.mapping.select_prev_item(),
          ['<C-d>'] = cmp.mapping.scroll_docs(-4),
          ['<C-f>'] = cmp.mapping.scroll_docs(4),
          ['<C-Space>'] = cmp.mapping.complete(),
          ['<C-e>'] = cmp.mapping.close(),
          ['<CR>'] = cmp.mapping.confirm { behavior = cmp.ConfirmBehavior.Replace, select = true },
          ['<Tab>'] = function(fallback)
             if cmp.visible() then cmp.select_next_item()
             elseif luasnip.expand_or_jumpable() then luasnip.expand_or_jump()
             else fallback() end
          end,
          ['<S-Tab>'] = function(fallback)
             if cmp.visible() then cmp.select_prev_item()
             elseif luasnip.jumpable(-1) then luasnip.jump(-1)
             else fallback() end
          end
        },
        sources = {
          { name = 'nvim_lsp' },
          { name = 'luasnip' },
          { name = 'path' },
          { name = 'buffer' },
        },
      })
    end
  },

  -- 9. LSP Config
  {
    "neovim/nvim-lspconfig",
    event = { "BufReadPre", "BufNewFile" },
    config = function()
      local lspconfig = require("lspconfig")
      local on_attach = function(client, bufnr)
        local opts = { buffer = bufnr }
        map("n", "gd", vim.lsp.buf.definition, opts)
        map("n", "K", vim.lsp.buf.hover, opts)
        map("n", "<leader>rn", vim.lsp.buf.rename, opts)
        map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
        vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
      end

      -- Lua
      if fn.executable("lua-language-server") == 1 then
        lspconfig.lua_ls.setup({
          on_attach = on_attach,
          settings = { Lua = { diagnostics = { globals = { "vim" } } } }
        })
      end

      -- C/C++
      if fn.executable("clangd") == 1 then
        lspconfig.clangd.setup({ on_attach = on_attach })
      end

      -- Python (Custom Detection Logic)
      api.nvim_create_autocmd("FileType", {
        pattern = "python",
        callback = function()
          if fn.executable("pyright-langserver") == 1 then
            vim.lsp.start({
              name = "pyright",
              cmd = { "pyright-langserver", "--stdio" },
              root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'pyproject.toml' }, { upward = true })[1]),
              on_attach = on_attach,
            })
          end
        end,
      })

      -- TS/JS (Custom Detection Logic)
      api.nvim_create_autocmd("FileType", {
        pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
        callback = function()
          if fn.executable("typescript-language-server") == 1 then
            vim.lsp.start({
              name = "ts_ls",
              cmd = { "typescript-language-server", "--stdio" },
              root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'package.json' }, { upward = true })[1]),
              on_attach = on_attach,
            })
          end
        end,
      })
    end
  }

}, {})

-- ==========================================================================
--  Non-Plugin Specific Autocmds
-- ==========================================================================

-- C/C++ Indentation
api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "cuda" },
  callback = function()
    local local_opt = vim.opt_local
    local_opt.cindent = true
    local_opt.cinoptions:append("g-0")
    local_opt.cinoptions:append("g0")
    local_opt.cinoptions:append("N-s")
    local_opt.tabstop = 4
    local_opt.shiftwidth = 4
    local_opt.expandtab = true
  end,
})

-- Lua Indentation
api.nvim_create_autocmd("FileType", {
  pattern = { "lua" },
  callback = function()
    local local_opt = vim.opt_local
    local_opt.tabstop = 2
    local_opt.shiftwidth = 2
  end,
})
