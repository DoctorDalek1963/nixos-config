{
  pkgs,
  config,
  ...
}: let
  inherit (config.consts.lib) optItemList;
  tt = config.setup.terminalTools;
in {
  imports = [
    ./bat.nix
    ./btop.nix
    ./comma.nix
    ./delta.nix
    ./fd.nix
    ./git.nix
    ./nvim.nix
    ./ripgrep.nix
  ];

  home.packages =
    optItemList tt.hyperfine pkgs.hyperfine
    ++ optItemList tt.sad pkgs.sad
    ++ optItemList tt.sd pkgs.sd
    ++ optItemList tt.tldr pkgs.tldr
    ++ optItemList tt.vim pkgs.vim;
}
