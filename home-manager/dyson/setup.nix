{
  pkgs,
  lib,
  config,
  ...
}:
with lib; let
  cfg = config.setup;
  inherit (config.consts.lib) optItemList;
  inherit (config.consts) valid-gnome-themes valid-shells;

  defaultTrue = mkOption {
    default = true;
    type = types.bool;
  };
  defaultFalse = mkOption {
    default = false;
    type = types.bool;
  };
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
      type = types.listOf (types.enum valid-shells);
    };
    defaultShell = mkOption {
      default = "bash";
      type = types.enum valid-shells;
    };

    # Terminal tools
    terminalTools = {
      # Need custom config
      bat = defaultTrue;
      btop = defaultTrue;
      delta = defaultTrue;
      fd = defaultTrue;
      git = defaultTrue;
      nvimCustom = defaultTrue;
      ripgrep = defaultTrue;

      # Just install the packages
      sad = defaultTrue;
      sd = defaultTrue;
      tldr = defaultTrue;
      vim = defaultTrue;
    };

    secrets = defaultTrue;

    # Desktop environments
    desktopEnvironments = {
      gnome = {
        enable = defaultFalse;
        enableExtensions = defaultTrue;
        theme = mkOption {
          type = types.enum valid-gnome-themes;
        };
        background = mkOption {
          type = types.either types.path (types.submodule {
            options = {
              light = mkOption {type = types.path;};
              dark = mkOption {type = types.path;};
            };
          });
        };
      };
    };

    programming = {
      miscTools = {
        git-all = defaultTrue;
        gh = defaultTrue;
        just = defaultTrue;
        pre-commit = defaultTrue;
      };

      haskell = defaultFalse;
      julia = defaultFalse;
      python = defaultFalse;
      rust = defaultFalse;

      nix = defaultTrue;
    };

    maths = {
      enable = defaultFalse;

      sage = defaultTrue;
      tikzit = defaultTrue;
      texlive = mkOption {
        type = types.nullOr types.package;
        default = pkgs.texlive.combine {inherit (pkgs.texlive) scheme-medium;};
      };
    };

    # Miscellaneous programs
    miscPrograms = {
      discord = defaultFalse; # Handled custom
      obsidian = defaultFalse;
      vlc = defaultTrue;
      zoom = defaultFalse;
    };
  };

  config = let
    tt = cfg.terminalTools;
    terminalToolsPkgs =
      optItemList tt.sad pkgs.sad
      ++ optItemList tt.sd pkgs.sd
      ++ optItemList tt.tldr pkgs.tldr
      ++ optItemList tt.vim pkgs.vim;

    mp = cfg.miscPrograms;
    miscProgramsPkgs =
      optItemList mp.obsidian pkgs.obsidian
      ++ optItemList mp.vlc pkgs.vlc
      ++ optItemList mp.zoom pkgs.zoom-us;
  in {
    # TODO: Do something with defaultShell
    home.packages =
      terminalToolsPkgs
      ++ miscProgramsPkgs
      ++ optItemList cfg.hasDvdDrive pkgs.handbrake;
  };
}
