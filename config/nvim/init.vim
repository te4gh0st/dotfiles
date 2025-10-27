"	$$$$$$$$\ $$$$$$$$\   $$\             $$\        $$$$$$\              $$\     
"	\__$$  __|$$  _____|$$$$ |            $$ |      $$$ __$$\             $$ |    
"	   $$ |   $$ |      \_$$ |   $$$$$$$\ $$$$$$$\  $$$$\ $$ | $$$$$$$\ $$$$$$\   
"	   $$ |   $$$$$\      $$ |  $$  _____|$$  __$$\ $$\$$\$$ |$$  _____|\_$$  _|  
"	   $$ |   $$  __|     $$ |  $$ /      $$ |  $$ |$$ \$$$$ |\$$$$$$\    $$ |    
"	   $$ |   $$ |        $$ |  $$ |      $$ |  $$ |$$ |\$$$ | \____$$\   $$ |$$\ 
"	   $$ |   $$$$$$$$\ $$$$$$\ \$$$$$$$\ $$ |  $$ |\$$$$$$  /$$$$$$$  |  \$$$$  |
"	   \__|   \________|\______| \_______|\__|  \__| \______/ \_______/    \____/

"Base"
:set number
:set autoindent
:set tabstop=4
:set shiftwidth=4
:set smarttab
:set softtabstop=4
:set mouse=a
:set termguicolors

"Plugins"
call plug#begin()

Plug 'vim-airline/vim-airline'
Plug 'vim-airline/vim-airline-themes'
Plug 'scrooloose/nerdtree'
Plug 'ap/vim-css-color'
Plug 'tpope/vim-surround'
Plug 'morhetz/gruvbox'
Plug 'EdenEast/nightfox.nvim'

call plug#end()

syntax enable
colorscheme carbonfox

let NERDTreeShowHidden = 1
nnoremap <C-n> :NERDTree<CR>
nnoremap <C-t> :NERDTreeToggle<CR>

" off arrows
nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

imap jj <ESC>
