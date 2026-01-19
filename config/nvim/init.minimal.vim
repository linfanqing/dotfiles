" ==========================================================================
"  Vim 7.4 Compatible Minimal Configuration
"  No plugins required - works completely offline
" ==========================================================================

set nocompatible
filetype plugin indent on
syntax enable

" ==========================================================================
"  Globals & Options
" ==========================================================================
let mapleader = ";"
let maplocalleader = ";"

" Options
set number
set tabstop=4
set shiftwidth=4
set expandtab
set smartindent
set ignorecase
set smartcase
set scrolloff=8
set updatetime=250
set nowrap
set noswapfile
set laststatus=2
set cursorline

" Better editing
set backspace=indent,eol,start
set wildmenu
set wildmode=longest:full,full
set incsearch
set hlsearch

" ==========================================================================
"  General Keymaps
" ==========================================================================
nnoremap <leader>q :q<CR>
nnoremap <leader>x :bd<CR>

" Search
nnoremap <Esc> :nohlsearch<CR>

" Window Navigation
nnoremap <leader>hw <C-w>h
nnoremap <leader>jw <C-w>j
nnoremap <leader>kw <C-w>k
nnoremap <leader>lw <C-w>l

" Build/Make
nnoremap <leader>m :wa<CR>:make<CR><CR>:cw<CR>

" UI Toggles
nnoremap <C-l> :set nu!<CR>

" Diffing
nnoremap <leader>dt :diffthis<CR>
nnoremap <leader>do :diffoff<CR>
nnoremap <leader>bd :set scb!<CR>

" Quickfix Navigation
nnoremap ]e :cn<CR>
nnoremap [e :cp<CR>

" File Explorer (netrw - built-in)
nnoremap <leader>r :Explore<CR>
nnoremap <leader>fl :Explore %:p:h<CR>

" FSwitch alternative - switch between .h and .cpp files
nnoremap <leader>of :call SwitchSourceHeader('edit')<CR>
nnoremap <leader>ol :call SwitchSourceHeader('vsplit')<CR>
nnoremap <leader>oL :call SwitchSourceHeader('vsplit')<CR>

" Comment toggling
nnoremap <leader>c :call ToggleComment()<CR>
vnoremap <leader>c :call ToggleCommentVisual()<CR>

" Ack/Search
nnoremap <leader>s :Ack<Space>

" ==========================================================================
"  Abbreviations
" ==========================================================================
iabbrev 10- ----------
iabbrev 80- --------------------------------------------------------------------------------
iabbrev 80= ================================================================================

" Command abbreviations
cnoreabbrev tb tabnew
cnoreabbrev S Ack

" ==========================================================================
"  Functions
" ==========================================================================

" Minimal Ack implementation using vimgrep or external grep
function! AckCommand(...)
    if a:0 == 0
        echo "Usage: :Ack <pattern> [path]"
        return
    endif

    let l:pattern = a:1
    let l:path = a:0 >= 2 ? a:2 : '.'

    " Save current error format
    let l:old_grepformat = &grepformat
    let l:old_grepprg = &grepprg

    " Try using external grep tools if available
    if executable('ag')
        set grepprg=ag\ --vimgrep\ $*
        set grepformat=%f:%l:%c:%m
        execute 'silent grep! ' . shellescape(l:pattern) . ' ' . l:path
    elseif executable('ack')
        set grepprg=ack\ --nogroup\ --nocolor\ --column
        set grepformat=%f:%l:%c:%m
        execute 'silent grep! ' . shellescape(l:pattern) . ' ' . l:path
    elseif executable('grep')
        set grepprg=grep\ -rn\ $*
        set grepformat=%f:%l:%m
        execute 'silent grep! ' . shellescape(l:pattern) . ' ' . l:path . ' 2>/dev/null'
    else
        " Fallback to vimgrep
        try
            execute 'silent vimgrep /' . l:pattern . '/gj **/*'
        catch
            echo "Search failed. Pattern: " . l:pattern
        endtry
    endif

    " Restore grep settings
    let &grepformat = l:old_grepformat
    let &grepprg = l:old_grepprg

    " Open quickfix window if there are results
    if len(getqflist()) > 0
        copen
    else
        echo "No matches found for: " . l:pattern
    endif
    redraw!
endfunction

command! -nargs=+ Ack call AckCommand(<f-args>)

" Set default grep program if ag or ack is available
if executable('ag')
    set grepprg=ag\ --vimgrep\ $*
    set grepformat=%f:%l:%c:%m
elseif executable('ack')
    set grepprg=ack\ --nogroup\ --nocolor\ --column
    set grepformat=%f:%l:%c:%m
endif

" Switch between source and header files (FSwitch alternative)
function! SwitchSourceHeader(cmd)
    let l:extension = expand('%:e')
    let l:basename = expand('%:r')
    let l:current_dir = expand('%:p:h')

    " Map extensions to their counterparts
    let l:header_exts = ['hpp', 'h', 'hxx', 'hh']
    let l:source_exts = ['cpp', 'c', 'cu', 'cc', 'cxx']

    let l:is_header = index(l:header_exts, l:extension) >= 0
    let l:is_source = index(l:source_exts, l:extension) >= 0

    if !l:is_header && !l:is_source
        echo "Not a C/C++ source or header file"
        return
    endif

    " Determine which extensions to try
    let l:try_exts = l:is_header ? l:source_exts : l:header_exts

    " Try to find counterpart file
    " First try in same directory
    for ext in l:try_exts
        let l:target = l:basename . '.' . ext
        if filereadable(l:target)
            execute a:cmd . ' ' . l:target
            return
        endif
    endfor

    " Try common directory patterns (include <-> src)
    if l:is_header
        " Try replacing 'include' with 'src' in path
        let l:alt_dir = substitute(l:current_dir, '/include\(/\|$\)', '/src\1', '')
    else
        " Try replacing 'src' with 'include' in path
        let l:alt_dir = substitute(l:current_dir, '/src\(/\|$\)', '/include\1', '')
    endif

    if l:alt_dir !=# l:current_dir
        let l:alt_basename = l:alt_dir . '/' . expand('%:t:r')
        for ext in l:try_exts
            let l:target = l:alt_basename . '.' . ext
            if filereadable(l:target)
                execute a:cmd . ' ' . l:target
                return
            endif
        endfor
    endif

    echo "No counterpart file found for " . expand('%:t')
endfunction

" Simple comment toggling
function! ToggleComment()
    let l:line = getline('.')
    let l:ft = &filetype

    " Determine comment string based on filetype
    if l:ft ==# 'vim'
        let l:comment = '"\s*'
        let l:comment_prefix = '" '
    elseif l:ft ==# 'python' || l:ft ==# 'sh' || l:ft ==# 'bash' || l:ft ==# 'ruby' || l:ft ==# 'perl'
        let l:comment = '#\s*'
        let l:comment_prefix = '# '
    elseif l:ft ==# 'lua'
        let l:comment = '--\s*'
        let l:comment_prefix = '-- '
    else
        " Default to C-style comments (c, cpp, cuda, javascript, java, etc.)
        let l:comment = '//\s*'
        let l:comment_prefix = '// '
    endif

    " Toggle comment
    if l:line =~# '^\s*' . l:comment
        " Remove comment - preserve indentation
        execute 's/^\(\s*\)' . l:comment . '/\1/'
    else
        " Add comment - preserve indentation
        execute 's/^\(\s*\)/\1' . l:comment_prefix . '/'
    endif
    nohlsearch
endfunction

function! ToggleCommentVisual() range
    let l:ft = &filetype

    " Determine comment string based on filetype
    if l:ft ==# 'vim'
        let l:comment = '"\s*'
        let l:comment_prefix = '" '
    elseif l:ft ==# 'python' || l:ft ==# 'sh' || l:ft ==# 'bash' || l:ft ==# 'ruby' || l:ft ==# 'perl'
        let l:comment = '#\s*'
        let l:comment_prefix = '# '
    elseif l:ft ==# 'lua'
        let l:comment = '--\s*'
        let l:comment_prefix = '-- '
    else
        " Default to C-style comments
        let l:comment = '//\s*'
        let l:comment_prefix = '// '
    endif

    " Check if first line is commented
    let l:first_line = getline(a:firstline)
    let l:is_commented = l:first_line =~# '^\s*' . l:comment

    " Toggle all lines in range
    for line_num in range(a:firstline, a:lastline)
        if l:is_commented
            execute line_num . 's/^\(\s*\)' . l:comment . '/\1/'
        else
            execute line_num . 's/^\(\s*\)/\1' . l:comment_prefix . '/'
        endif
    endfor
    nohlsearch
endfunction

" ==========================================================================
"  Autocmds
" ==========================================================================
if has("autocmd")
    " C/C++/CUDA Indentation
    augroup cpp_indent
        autocmd!
        autocmd FileType c,cpp,cuda setlocal cindent cinoptions=g-0,g0,N-s
        autocmd FileType c,cpp,cuda setlocal tabstop=4 shiftwidth=4 expandtab
    augroup END

    " Lua Indentation
    augroup lua_indent
        autocmd!
        autocmd FileType lua setlocal tabstop=2 shiftwidth=2
    augroup END

    " Python Indentation
    augroup python_indent
        autocmd!
        autocmd FileType python setlocal tabstop=4 shiftwidth=4 expandtab
    augroup END

    " Auto-open quickfix after grep/make
    augroup quickfix
        autocmd!
        autocmd QuickFixCmdPost [^l]* cwindow
    augroup END
endif

" ==========================================================================
"  Netrw Settings (built-in file explorer)
" ==========================================================================
" let g:netrw_banner = 0          " Hide banner
" let g:netrw_liststyle = 3       " Tree view
" let g:netrw_browse_split = 0    " Open in same window
" let g:netrw_winsize = 25        " 25% width
" let g:netrw_altv = 1            " Open splits to the right
let g:netrw_list_hide = '^\.,\.pyc$,__pycache__'  " Hide dotfiles and Python cache

" ==========================================================================
"  Color Scheme
" ==========================================================================
set background=dark

" Use termguicolors if available (Vim 8.0+)
if has("termguicolors")
    set termguicolors
endif

" Try to use a nice built-in colorscheme
silent! colorscheme desert

" ==========================================================================
"  Status Line
" ==========================================================================
set statusline=%f               " File path (relative)
set statusline+=\ %m            " Modified flag [+]
set statusline+=\ %r            " Readonly flag [RO]
set statusline+=%=              " Right align from here
set statusline+=\ %y            " File type [vim]
set statusline+=\ %l:%c         " Line:Column
set statusline+=\ %p%%          " Percentage through file
set statusline+=\ [%L]          " Total lines

" ==========================================================================
"  Additional Useful Settings
" ==========================================================================

" Enable mouse support if available
if has('mouse')
    set mouse=a
endif

" Better split defaults
set splitright
set splitbelow

" Show matching brackets
set showmatch

" Command line height
set cmdheight=1

" Don't show mode in command line (already in statusline)
set noshowmode

" Minimal folds configuration
set foldmethod=indent
set foldlevel=99

" Persistent undo if available (Vim 7.3+)
if has('persistent_undo')
    set undodir=~/.vim/undo
    set undofile
    " Create undo directory if it doesn't exist
    if !isdirectory(expand('~/.vim/undo'))
        call mkdir(expand('~/.vim/undo'), 'p', 0700)
    endif
endif

" ==========================================================================
"  End of Configuration
" ==========================================================================

