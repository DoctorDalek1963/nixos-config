{
  pkgs,
  config,
  ...
}: let
  inherit (config.consts.lib) optItemList;
  tt = config.setup.terminal.tools;
  inherit (config.consts) nvimPkg nvimPath;
in {
  imports = [
    ./aria2.nix
    ./bat.nix
    ./btop.nix
    ./comma.nix
    ./delta.nix
    ./fd.nix
    ./fzf.nix
    ./git.nix
    ./ripgrep.nix
  ];

  home = {
    packages =
      [nvimPkg]
      ++ optItemList tt.eza pkgs.eza
      ++ optItemList tt.hyperfine pkgs.hyperfine
      ++ optItemList tt.sad pkgs.sad
      ++ optItemList tt.sd pkgs.sd
      ++ optItemList tt.tldr pkgs.tldr
      ++ optItemList tt.yt-dlp pkgs.yt-dlp;

    sessionVariables.EDITOR = nvimPath;
  };
}
