{
  pkgs,
  lib,
  config,
  inputs,
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

  file-modules = [
    ./consts.nix

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

    # Secrets
    ./modules/secrets/provisioning.nix
    ./modules/secrets/gnome-keyring.nix

    # Desktop environments
    # Each default.nix file here also imports any other necessary nix files
    ./modules/desktopEnvironments/gnome/default.nix

    ./modules/firefox/default.nix

    # Programming
    ./modules/programming/miscTools.nix
    ./modules/programming/haskell.nix
    ./modules/programming/julia.nix
    ./modules/programming/nix.nix
    ./modules/programming/python.nix
    ./modules/programming/rust.nix

    ./modules/maths/default.nix

    ./modules/gaming.nix

    # Misc programs
    ./modules/miscPrograms/discord.nix
  ];
  other-modules = [inputs.sops-nix.homeManagerModules.sops];
in {
  imports = file-modules ++ other-modules;

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

    firefox = {
      enable = defaultFalse;
      enableExtensions = defaultTrue;
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
      texlive = {
        enable = defaultTrue;
        pkg = mkOption {
          type = types.package;
          default = pkgs.texlive.combine {inherit (pkgs.texlive) scheme-medium;};
        };
      };
    };

    gaming = defaultFalse;

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
