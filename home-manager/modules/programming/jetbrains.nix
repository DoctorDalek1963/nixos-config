{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.jetbrains {
    # Note that we don't actually install any JetBrains IDEs here. Nor do we
    # install Android Studio in ./android.nix. This is because the IDEs are
    # heavy and most are unnecessary for me, so I only install them on a
    # per-project basis.

    setup.impermanence.keepDirs = [
      # JetBrains IDEs
      ".config/JetBrains"
      ".local/share/JetBrains"
    ];

    home.file.".ideavimrc".text = ''
      let mapleader = '\'

      set ideajoin

      syntax on
      filetype indent plugin on

      set number relativenumber
      set ruler
      set ignorecase smartcase hlsearch incsearch

      set foldenable
      set foldmethod=indent

      set scrolloff=2

      " Easier 4 directional navigation in panes
      nmap <C-j> <C-w>j
      nmap <C-k> <C-w>k
      nmap <C-h> <C-w>h
      nmap <C-l> <C-w>l

      " Duplicate line with Ctrl+D
      nnoremap <C-d> yyp

      " Toggle folding with space
      nnoremap <space><space> za
      nnoremap <leader><space> zA

      " Write current file
      nnoremap <leader>w :w<Enter>
      nnoremap <leader><leader> :w<Enter>

      " Add a semicolon or comma to the end of a line
      nnoremap <leader>; mqA;<esc>`qdmq
      nnoremap <leader>, mqA,<esc>`qdmq

      " Remove search highlight
      nnoremap <leader>n :nohlsearch<cr>
    '';
  };
}
