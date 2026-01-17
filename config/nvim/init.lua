-- ==========================================================================
--  Local Aliases
-- ==========================================================================
local g = vim.g
local fn  = vim.fn
local opt = vim.opt
local map = vim.keymap.set
local cmd = vim.cmd
local api = vim.api
local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd
local cabbrev = vim.cmd.cabbrev
local iabbrev = vim.cmd.iabbrev
local cnoreabbrev = vim.cmd.cnoreabbrev

-- ==========================================================================
--  Common Setups
-- ==========================================================================
opt.number         = true       -- Show line numbers
opt.tabstop        = 4          -- Number of spaces that a <Tab> in the file counts for
opt.shiftwidth     = 4          -- Size of an indent
opt.expandtab      = true       -- Use spaces instead of tabs
opt.smartindent    = true       -- Insert indents automatically
opt.ignorecase     = true       -- Ignore case in search patterns
opt.smartcase      = true       -- ...unless the pattern contains upper case
opt.termguicolors  = true       -- True color support (required for Gruvbox)
opt.scrolloff      = 8          -- Keep 8 lines above/below cursor
opt.updatetime     = 250        -- Faster update time for CursorHold events
opt.wrap           = false      -- Don't wrap
opt.swapfile       = false      -- Don't use swapfile
opt.laststatus     = 3          -- Set global statusline
opt.cursorline     = true       -- Highlight current row

-- ==========================================================================
--  Plugin Bootstrap (Lazy.nvim)
-- ==========================================================================
local lazypath = fn.stdpath("data") .. "/lazy/lazy.nvim"
if not vim.loop.fs_stat(lazypath) then
  fn.system({
    "git",
    "clone",
    "--filter=blob:none",
    "https://github.com/folke/lazy.nvim.git",
    "--branch=stable",
    lazypath
  })
end
opt.rtp:prepend(lazypath)

require("lazy").setup({
  -- FSwitch
  { 'derekwyatt/vim-fswitch' },

  -- Theme
  { "catppuccin/nvim", name = "catppuccin", priority = 1000 },

  -- Legacy LSP Support (Optional but standard)
  { "neovim/nvim-lspconfig" },

  -- Nerdtree
	{ 'preservim/nerdtree' },

  -- NerdCommenter
  { 'scrooloose/nerdcommenter' },

  -- Ack
  { 'mileszs/ack.vim' },

  -- Autocomplete
  {
    'hrsh7th/nvim-cmp',
    -- load cmp on InsertEnter
    event = 'InsertEnter',
    -- these dependencies will only be loaded when cmp loads
    -- dependencies are always lazy-loaded unless specified otherwise
    dependencies = {
      'L3MON4D3/LuaSnip',
      'hrsh7th/cmp-nvim-lsp',
      'hrsh7th/cmp-path',
      'hrsh7th/cmp-buffer',
      'saadparwaiz1/cmp_luasnip',
    },
  },

  -- Git labels
  {
    'lewis6991/gitsigns.nvim',
    lazy = true,
    dependencies = {
      'nvim-lua/plenary.nvim',
      'kyazdani42/nvim-web-devicons',
    },
  },

  -- Fugitive
  { 'tpope/vim-fugitive' },
})

-- ==========================================================================
--  Theme
-- ==========================================================================

require("catppuccin").setup({
  flavour = "frappe", -- latte, frappe, macchiato, mocha
  -- flavour = "auto" -- will respect terminal's background
  background = { -- :h background
    light = "latte",
    dark = "mocha",
  },
  transparent_background = true, -- disables setting the background color.
  show_end_of_buffer = false, -- shows the '~' characters after the end of buffers
  term_colors = false, -- sets terminal colors (e.g. `g:terminal_color_0`)
  dim_inactive = {
    enabled = false, -- dims the background color of inactive window
    shade = "dark",
    percentage = 0.15, -- percentage of the shade to apply to the inactive window
  },
  no_italic = false, -- Force no italic
  no_bold = false, -- Force no bold
  no_underline = false, -- Force no underline
  styles = { -- Handles the styles of general hi groups (see `:h highlight-args`):
    comments = { "italic" }, -- Change the style of comments
    conditionals = { "italic" },
    loops = {},
    functions = {},
    keywords = {},
    strings = {},
    variables = {},
    numbers = {},
    booleans = {},
    properties = {},
    types = {},
    operators = {},
    -- miscs = {}, -- Uncomment to turn off hard-coded styles
  },
  color_overrides = {},
  custom_highlights = {},
  default_integrations = true,
  integrations = {
    cmp = true,
    gitsigns = true,
    nvimtree = true,
    treesitter = true,
    notify = false,
    mini = {
        enabled = true,
        indentscope_color = "",
    },
  },
})

require("catppuccin").load()

-- ==========================================================================
--  General Keymaps
-- ==========================================================================

-- Leader Key
vim.g.mapleader = ";"
vim.g.maplocalleader = ";"

map("n", "<leader>q", "<cmd>q<cr>", { desc = "Quit" })

map('n', '<leader>x', ':bd<CR>', { desc = "Unload buffer" })

-- Clear highlight on Esc
map("n", "<Esc>", "<cmd>nohlsearch<cr>")

-- Window/Pane Navigation
map("n", "<leader>hw", "<C-w>h", { desc = "Window Left" })
map("n", "<leader>jw", "<C-w>j", { desc = "Window Down" })
map("n", "<leader>kw", "<C-w>k", { desc = "Window Up" })
map("n", "<leader>lw", "<C-w>l", { desc = "Window Right" })

-- Make
map('n', '<leader>m', ':wa<CR>:make<CR><CR>:cw<CR>')

-- Toggle line number
map('n', '<C-l>', ':set nu!<CR>')

-- Shortcut for diff
map('n', '<leader>dt', ':diffthis<CR>')
map('n', '<leader>do', ':diffoff<CR>')
map('n', '<leader>bd', ':set scb!<CR>')

-- Navigate
map('n', ']e', ':cn<CR>') -- Next error
map('n', '[e', ':cp<CR>') -- Prev error

-- Silly abbreviations
iabbrev("10-", "----------")
iabbrev("80-", "--------------------------------------------------------------------------------")
iabbrev("80=", "================================================================================")
iabbrev("80/", "////////////////////////////////////////////////////////////////////////////////")
iabbrev("70-", "---------------------------------------------------------------------")
iabbrev("70=", "=====================================================================")
iabbrev("77-", "-----------------------------------------------------------------------------")

-- ==========================================================================
--  LSP CONFIGURATION
-- ==========================================================================

local on_attach = function(client, bufnr)
  local opts = { buffer = bufnr }
  map("n", "gd", vim.lsp.buf.definition, opts)
  map("n", "K", vim.lsp.buf.hover, opts)
  map("n", "<leader>rn", vim.lsp.buf.rename, opts)
  map("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  -- Native Completion trigger
  vim.bo[bufnr].omnifunc = "v:lua.vim.lsp.omnifunc"
end

local lspconfig = require("lspconfig")

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

-- Python
api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function(ev)
    if fn.executable("pyright-langserver") == 1 then
      vim.lsp.start({
        name = "pyright",
        cmd = { "pyright-langserver", "--stdio" },
        -- Find root by looking for .git or pyproject.toml
        root_dir = vim.fs.dirname(vim.fs.find({ '.git', 'pyproject.toml' }, { upward = true })[1]),
        on_attach = on_attach,
      })
    end
  end,
})

-- Typescript/JS
api.nvim_create_autocmd("FileType", {
  pattern = { "javascript", "typescript", "javascriptreact", "typescriptreact" },
  callback = function(ev)
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

-- ==========================================================================
--  Misc
-- ==========================================================================

-- Highlight on yank
augroup('YankHighlight', { clear = true })
autocmd('TextYankPost', {
  group = 'YankHighlight',
  callback = function()
    vim.highlight.on_yank({ higroup = 'IncSearch', timeout = '1000' })
  end
})

-- ==========================================================================
--  FSwitch
-- ==========================================================================

function set_fswitch(pattern, cmd)
  autocmd('Filetype', {
    pattern = pattern,
    command = cmd,
  })
end

set_fswitch({'*.cpp'}, "let b:fswitchdst = 'hpp,h'")
set_fswitch({'*.hpp'}, "let b:fswitchdst = 'cpp,cu'")
set_fswitch({'*.cuh'}, "let b:fswitchdst = 'cu' | let b:fswitchlocs = 'reg:/include/src/'")
set_fswitch({'*.cu'},  "let b:fswitchdst = 'cuh,hpp' | let b:fswitchlocs = 'reg:/src/include/'")
set_fswitch({'*.h'},   "let b:fswitchdst = 'cpp,c' | let b:fswitchlocs = 'reg:/include/src/'")

map('n', '<Leader>of', ':FSHere<cr>', { silent = true })
map('n', '<Leader>ol', ':FSRight<cr>', { silent = true })
map('n', '<Leader>oL', ':FSSplitRight<cr>', { silent = true })

-- ==========================================================================
--  NERDComment
-- ==========================================================================

map('n', '<leader>c', '<plug>NERDCommenterToggle', { silent = true })
map('v', '<leader>c', '<plug>NERDCommenterToggle', { silent = true })

-- ==========================================================================
--  NERDTree
-- ==========================================================================

-- Toggle tree
map('n', '<leader>r', ':NERDTreeToggle<CR>', {})

-- Locate current file
map('n', '<leader>fl', ':NERDTreeFind<CR>', {})

g.NERDTreeAutoDeleteBuffer = 1
g.NERDTreeIgnore = {  }
g.NERDTreeMinimalUI = 1
g.NERDTreeRespectWildIgnore = 1
g.NERDTreeShowBookmarks = 1
g.NERDTreeShowHidden = 0
g.NERDTreeWinSize = 32
g.NERDTreeIgnore = {"__pycache__"}

g.NERDTreeCustomOpenArgs = {
    file = {
        reuse = 't',
        where = 'v',
        keepopen = true,
    },
    dir = {}
}

-- ==========================================================================
--  Autocomplete
-- ==========================================================================

local cmp = require('cmp')

local luasnip = require('luasnip')

cmp.setup {
  -- Load snippet support
  snippet = {
    expand = function(args)
      luasnip.lsp_expand(args.body)
    end,
  },

  -- Completion settings
  completion = {
    keyword_length = 2
  },

  -- Key mapping
  mapping = {
    ['<C-n>'] = cmp.mapping.select_next_item(),
    ['<C-p>'] = cmp.mapping.select_prev_item(),
    ['<C-d>'] = cmp.mapping.scroll_docs(-4),
    ['<C-f>'] = cmp.mapping.scroll_docs(4),
    ['<C-Space>'] = cmp.mapping.complete(),
    ['<C-e>'] = cmp.mapping.close(),
    ['<CR>'] = cmp.mapping.confirm {
      behavior = cmp.ConfirmBehavior.Replace,
      select = true,
    },

    -- Tab mapping
    ['<Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_next_item()
      elseif luasnip.expand_or_jumpable() then
        luasnip.expand_or_jump()
      else
        fallback()
      end
    end,
    ['<S-Tab>'] = function(fallback)
      if cmp.visible() then
        cmp.select_prev_item()
      elseif luasnip.jumpable(-1) then
        luasnip.jump(-1)
      else
        fallback()
      end
    end
  },

  -- Load sources, see: https://github.com/topics/nvim-cmp
  sources = {
    { name = 'nvim_lsp' },
    { name = 'luasnip' },
    { name = 'path' },
    { name = 'buffer' },
  },
}

-- ==========================================================================
--  Git labels
-- ==========================================================================

require('gitsigns').setup{
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

    -- Text object
    map({'o', 'x'}, 'ih', ':<C-U>Gitsigns select_hunk<CR>')
  end
}

-- ==========================================================================
--  Ack Setups
-- ==========================================================================
map('n', '<leader>s', ':Ack!<CR>')
cnoreabbrev('S', 'Ack')

-- ==========================================================================
--  C++ Setups
-- ==========================================================================

api.nvim_create_autocmd("FileType", {
  pattern = { "c", "cpp", "cuda" }, -- Matches filetype names, not extensions
  callback = function()
    local opt = vim.opt_local

    -- Enable the native C-indent engine
    opt.cindent = true

    -- Set the flags
    opt.cinoptions:append("g-0")
    opt.cinoptions:append("g0")
    opt.cinoptions:append("N-s")

    opt.tabstop = 4
    opt.shiftwidth = 4
    opt.expandtab = true
  end,
})

-- ==========================================================================
--  Lua Setups
-- ==========================================================================

api.nvim_create_autocmd("FileType", {
  pattern = { "lua" }, -- Matches filetype names, not extensions
  callback = function()
    local opt = vim.opt_local
    opt.tabstop = 2
    opt.shiftwidth = 2
  end,
})
