{
  pkgs,
  config,
  ...
}: let
  inherit (config.consts.lib) optItemList;
  tt = config.setup.terminalTools;
  inherit (config.consts) nvimPkg nvimPath;
in {
  imports = [
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
      ++ optItemList tt.hyperfine pkgs.hyperfine
      ++ optItemList tt.sad pkgs.sad
      ++ optItemList tt.sd pkgs.sd
      ++ optItemList tt.tldr pkgs.tldr;

    sessionVariables.EDITOR = nvimPath;
  };
}
