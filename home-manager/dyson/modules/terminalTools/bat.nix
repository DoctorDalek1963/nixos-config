{
  pkgs,
  config,
  ...
}: {
  programs.bat = {
    enable = config.setup.terminalTools.bat;
    config = {
      theme = "OneHalfDark";
      italic-text = "always";
    };
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
}
