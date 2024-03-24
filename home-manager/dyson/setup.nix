{
  pkgs,
  lib,
  config,
  inputs,
  ...
}:
with lib; let
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

    ./modules/shells/default.nix
    ./modules/terminalTools/default.nix
    ./modules/secrets/default.nix
    ./modules/desktopEnvironments/default.nix
    ./modules/firefox/default.nix
    ./modules/programming/default.nix
    ./modules/maths/default.nix
    ./modules/gaming/default.nix
    ./modules/miscPrograms/default.nix
  ];
  other-modules = [
    inputs.sops-nix.homeManagerModules.sops
    inputs.xremap.homeManagerModules.default
  ];
in {
  imports = file-modules ++ other-modules;

  options.setup = {
    username = mkOption {
      type = types.nonEmptyStr;
    };
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
    isLaptop = defaultFalse;
    hasDvdDrive = defaultFalse;

    shells = mkOption {
      default = ["bash"];
      type = types.listOf (types.enum valid-shells);
    };
    defaultShell = mkOption {
      default = "bash";
      type = types.enum valid-shells;
    };

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

    miscPrograms = {
      discord = defaultFalse;
      handbrake = defaultFalse; # DVD ripper
      obsidian = defaultFalse;
      vlc = defaultFalse;
      xremap = defaultFalse;
      zoom = defaultFalse;
    };
  };
}
