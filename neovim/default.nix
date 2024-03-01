{...}: {
  imports = [
    ./autoCmdGroups.nix
    ./globals.nix
    ./keymaps.nix
    ./options.nix
    ./plugins/default.nix
  ];

  programs.nixvim = {
    enable = true;
    defaultEditor = true;
    viAlias = true;
    vimAlias = true;

    clipboard.register = "unnamedplus";

    colorschemes.onedark.enable = true;

    userCommands = {
      Rmsp = {
        desc = "Remove all trailing spaces";
        command = "execute '%s/\\s\\+$//e'";
      };
    };

    highlight = {
      CocHintSign.link = "Comment";
    };

    extraConfigVim = ''
      function! LightlineReadonly()
          return &readonly && &filetype !=# "help" ? "RO" : ""
      endfunction

      function! LightlineFileformat()
          return &fileformat !=# "unix" ? &fileformat : ""
      endfunction

      function! VisualWordsAndChars()
          if mode() == "v"
              return wordcount().visual_words . "W " . wordcount().visual_chars . "C"
          else
              return ""
          endif
      endfunction

      function! UpdateGitPS1Status()
          let s:git_directory = substitute(resolve(expand("%:p")), '\/[^/]\+$', "", "")

          if s:git_directory == "" |
              let g:git_ps1_status = "" |
          else |
              let g:git_ps1_status = system("(cd '" . s:git_directory . "'; GIT_PS1_SHOWDIRTYSTATE=true; GIT_PS1_SHOWSTASHSTATE=true; GIT_PS1_SHOWUNTRACKEDFILES=true; GIT_PS1_SHOWUPSTREAM='auto'; GIT_PS1_HIDE_IF_PWD_IGNORED=true; source ~/.git-prompt.sh; __git_ps1 '[%s]')") |
          endif
      endfunction

      function! GitPS1Status()
          return g:git_ps1_status
      endfunction
    '';
  };
}
