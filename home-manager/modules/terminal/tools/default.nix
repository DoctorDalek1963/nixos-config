{
  pkgs,
  lib,
  config,
  ...
}: let
  tt = config.setup.terminal.tools;
  inherit (config.consts) nvimPkg nvimPath;
in {
  imports = [
    ./aria2.nix
    ./bat.nix
    ./btop.nix
    ./comma.nix
    ./delta.nix
    ./direnv.nix
    ./eza.nix
    ./fd.nix
    ./fzf.nix
    ./gh.nix
    ./git-all.nix
    ./git.nix
    ./just.nix
    ./lazygit.nix
    ./ripgrep.nix
  ];

  home = {
    packages =
      [nvimPkg]
      ++ lib.optional tt.hyperfine pkgs.hyperfine
      ++ lib.optional tt.sad pkgs.sad
      ++ lib.optional tt.sd pkgs.sd
      ++ lib.optional tt.tldr pkgs.tldr
      ++ lib.optional tt.yt-dlp pkgs.yt-dlp;

    sessionVariables.EDITOR = nvimPath;
  };
}
