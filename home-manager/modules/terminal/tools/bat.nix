{
  pkgs,
  lib,
  config,
  ...
}:
let
  catppuccin-src = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "bat";
    rev = "6810349b28055dce54076712fc05fc68da4b8ec0";
    sha256 = "sha256-lJapSgRVENTrbmpVyn+UQabC9fpV1G1e+CdlJ090uvg=";
  };

  theme =
    if config.programs.noctalia-shell.enable then
      {
        name = "noctalia";
        pkgs = {
          catppuccin-macchiato = {
            src = catppuccin-src;
            file = "themes/Catppuccin Macchiato.tmTheme";
          };
          catppuccin-latte = {
            src = catppuccin-src;
            file = "themes/Catppuccin Latte.tmTheme";
          };
        };
      }
    else
      {
        onedark = {
          name = "OneHalfDark";
          pkgs = { }; # Built-in to bat
        };
        catppuccin-macchiato = {
          name = "catppuccin-macchiato";
          pkgs = {
            catppuccin-macchiato = {
              src = catppuccin-src;
              file = "themes/Catppuccin Macchiato.tmTheme";
            };
          };
        };
      }
      .${config.setup.terminal.theme};
in
{
  config = lib.mkIf config.setup.terminal.tools.bat {
    programs.bat = {
      enable = true;
      config = {
        theme = theme.name;
        italic-text = "always";
      };
      themes = theme.pkgs;
      syntaxes = {
        just = {
          src = pkgs.fetchFromGitHub {
            owner = "nk9";
            repo = "just_sublime";
            rev = "352bae277961d41e2a1795a834dbf22661c8910f";
            hash = "sha256-QCp6ypSBhgGZG4T7fNiFfCgZIVJoDSoJBkpcdw3aiuQ=";
          };
          file = "Syntax/Just.sublime-syntax";
        };
        ron = {
          src = pkgs.fetchFromGitHub {
            owner = "ron-rs";
            repo = "sublime-ron";
            rev = "41e3e37db9febbf9dfc4efad015934c61b3c8ef1";
            hash = "sha256-t7ILpYizGIoICKe3NzBkeb9fzou0d7NkyDjLIUsa9KE=";
          };
          file = "RON.sublime-syntax";
        };
        wolfram = {
          src = pkgs.fetchFromGitHub {
            owner = "WolframResearch";
            repo = "Sublime-WolframLanguage";
            rev = "1d2da4b347a03d07e1b816a25a02c1a992230d3a";
            hash = "sha256-9MaD96xBAHF4ubuvoqMz3uJGUHE36lIiuOjJkAAucTI=";
          };
          file = "WolframLanguage.sublime-syntax";
        };
      };
    };

    setup.terminal.shellAliases.b = "${config.programs.bat.package}/bin/bat";
  };
}
