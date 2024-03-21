{
  pkgs,
  config,
  ...
}: let
  inherit (config.consts) optItemList;
  tt = config.setup.terminalTools;
in {
  imports = [
    ./bat.nix
    ./btop.nix
    ./delta.nix
    ./fd.nix
    ./git.nix
    ./nvim.nix
    ./ripgrep.nix
  ];

  home.packages =
    optItemList tt.sad pkgs.sad
    ++ optItemList tt.sd pkgs.sd
    ++ optItemList tt.tldr pkgs.tldr
    ++ optItemList tt.vim pkgs.vim;
}
