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
    ./modules/activation.nix

    ./modules/shells/default.nix
    ./modules/terminalTools/default.nix
    ./modules/secrets/default.nix
    ./modules/desktopEnvironments/default.nix
    ./modules/firefox/default.nix
    ./modules/rclone/default.nix
    ./modules/programming/default.nix
    ./modules/maths/default.nix
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

    rclone = {
      enable = defaultFalse;
      automounts = mkOption {
        default = [];
        type = types.listOf (types.submodule {
          options = {
            remote = mkOption {
              type = types.nonEmptyStr;
              description = "The name of the remote server to mount.";
            };
            mountpoint = mkOption {
              type = types.nonEmptyStr;
              description = "The full path of the folder to mount the remote into.";
            };
            readonly = mkOption {
              type = types.bool;
              default = false;
              description = "Should this mount be readonly?";
            };
            extraArgs = mkOption {
              type = types.str;
              default = "";
              description = "Any extra args to pass to the `rclone mount` command.";
            };
          };
        });
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
      texlive = {
        enable = defaultTrue;
        pkg = mkOption {
          type = types.package;
          default = pkgs.texlive.combine {inherit (pkgs.texlive) scheme-medium;};
        };
      };
    };

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
