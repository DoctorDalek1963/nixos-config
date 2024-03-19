{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.setup;

  available-shells = ["bash"];

  defaultTrue = mkOption {
    default = true;
    type = types.bool;
  };
  defaultFalse = mkOption {
    default = false;
    type = types.bool;
  };

  optItemList = opt: item:
    if opt
    then [item]
    else [];
in {
  options.setup = {
    # General stuff
    username = mkOption {
      type = types.nonEmptyStr;
    };
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
    isLaptop = defaultFalse;
    hasDvdDrive = defaultFalse;

    # Shells
    shells = mkOption {
      default = ["bash"];
      type = types.listOf (types.enum available-shells);
    };
    defaultShell = mkOption {
      default = "bash";
      type = types.enum available-shells;
    };

    # Terminal tools
    terminalTools = {
      # Need custom config
      bat = defaultTrue;
      btop = defaultTrue;
      delta = defaultTrue;
      fd = defaultTrue;
      git = defaultTrue;
      nvim = defaultTrue;
      ripgrep = defaultTrue;

      # Just install the packages
      sad = defaultTrue;
      sd = defaultTrue;
      tldr = defaultTrue;
      vim = defaultTrue;
    };
  };

  config = let
    terminalToolsPkgs =
      optItemList cfg.terminalTools.sad pkgs.sad
      ++ optItemList cfg.terminalTools.sd pkgs.sd
      ++ optItemList cfg.terminalTools.tldr pkgs.tldr
      ++ optItemList cfg.terminalTools.vim pkgs.vim;
  in {
    imports = [
      ./modules/core.nix

      # Shells
      ./modules/shells/bash.nix

      # Terminal tools
      ./modules/terminalTools/bat.nix
      ./modules/terminalTools/btop.nix
      ./modules/terminalTools/delta.nix
      ./modules/terminalTools/fd.nix
      ./modules/terminalTools/git.nix
      ./modules/terminalTools/nvim.nix
      ./modules/terminalTools/ripgrep.nix
    ];
    # TODO: Do something with defaultShell
    home.packages =
      terminalToolsPkgs
      ++ optItemList cfg.hasDvdDrive pkgs.handbrake;
  };
}
