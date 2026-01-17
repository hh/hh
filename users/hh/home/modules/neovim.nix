# Neovim configuration
{
  config,
  lib,
  pkgs,
  ...
}: {
  programs.neovim = {
    enable = true;
    defaultEditor = true;
    vimAlias = true;
    viAlias = true;

    extraConfig = ''
      " Basic settings
      set number
      set relativenumber
      set expandtab
      set tabstop=2
      set shiftwidth=2
      set smartindent
      set termguicolors
      set mouse=a
      set clipboard=unnamedplus
      set ignorecase
      set smartcase
      set undofile

      " Leader key
      let mapleader = " "

      " Quick save and quit
      nnoremap <leader>w :w<CR>
      nnoremap <leader>q :q<CR>

      " Better window navigation
      nnoremap <C-h> <C-w>h
      nnoremap <C-j> <C-w>j
      nnoremap <C-k> <C-w>k
      nnoremap <C-l> <C-w>l

      " Clear search highlight
      nnoremap <leader>h :nohlsearch<CR>
    '';

    plugins = with pkgs.vimPlugins; [
      # Theme
      dracula-vim

      # Essentials
      vim-sensible
      vim-surround
      vim-commentary
      vim-fugitive

      # File navigation
      telescope-nvim
      plenary-nvim
      nvim-web-devicons

      # Syntax
      nvim-treesitter.withAllGrammars

      # LSP
      nvim-lspconfig

      # Status line
      lualine-nvim
    ];
  };
}
