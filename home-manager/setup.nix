{
  lib,
  config,
  inputs,
  ...
}: let
  inherit (lib) mkOption types;
  inherit (config.consts) valid-gnome-themes valid-terminal-themes valid-shells;

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
    ./modules/fonts.nix

    ./modules/terminal
    ./modules/desktopEnvironments
    ./modules/firefox
    ./modules/maths
    ./modules/miscPrograms
    ./modules/office
    ./modules/programming
    ./modules/rclone
    ./modules/secrets
  ];
  other-modules = [
    inputs.nix-index-database.hmModules.nix-index
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
    isNixOS = mkOption {
      type = types.bool;
    };

    isLaptop = defaultFalse;

    # === Shell and terminal stuff

    terminal = {
      shells = {
        bash = defaultTrue;
      };
      defaultShell = mkOption {
        default = "bash";
        type = types.enum valid-shells;
      };

      emulators = {
        terminator = defaultFalse;
        wezterm = defaultTrue;
      };
      defaultEmulator = mkOption {
        default = "wezterm";
        type = types.enum ["terminator" "wezterm"];
      };

      multiplexer = mkOption {
        default = "zellij";
        type = types.enum ["none" "zellij"];
      };

      theme = mkOption {
        type = types.enum valid-terminal-themes;
        default = "onedark";
      };
      useThemeInTerminalItself = defaultFalse;

      tools = {
        # Need custom config
        aria2 = defaultTrue;
        bat = defaultTrue;
        btop = {
          enable = defaultTrue;
          gpuSupport = defaultTrue;
        };
        comma = defaultTrue;
        delta = defaultTrue;
        fd = defaultTrue;
        fzf = defaultTrue;
        git = defaultTrue;
        nvim = mkOption {
          type = types.enum ["basic" "small" "medium" "full"];
          default = "medium";
        };
        ripgrep = defaultTrue;

        # Just install the packages
        eza = defaultTrue;
        hyperfine = defaultTrue;
        sad = defaultTrue;
        sd = defaultTrue;
        tldr = defaultTrue;
        yt-dlp = defaultFalse;
      };
    };

    # === Desktop stuff
    desktopEnvironments = {
      background = mkOption {
        type = types.either types.path (types.submodule {
          options = {
            light = mkOption {type = types.path;};
            dark = mkOption {type = types.path;};
          };
        });
      };
      cinnamon = {
        enable = defaultFalse;
        menuIcon = mkOption {
          type = types.nullOr types.path;
          default = null;
        };
        theme = {
          cursor = mkOption {
            type = types.nonEmptyStr;
          };
          gtk = mkOption {
            type = types.nonEmptyStr;
          };
        };
      };
      gnome = {
        enable = defaultFalse;
        enableExtensions = defaultTrue;
        theme = mkOption {
          type = types.enum valid-gnome-themes;
        };
      };
    };

    # === Firefox
    firefox = {
      enable = defaultFalse;
      minimal = defaultFalse;
      enableExtensions = defaultTrue;
    };

    # === Fonts
    fonts = {
      hackNerdFont = defaultTrue;
      microsoftFonts = defaultFalse;
    };

    # === Maths
    maths = {
      enable = defaultFalse;

      lintrans = defaultTrue;
      octave = defaultTrue;
      sage = defaultTrue;
      tikzit = defaultTrue;
      weylus = defaultTrue;
      zotero = defaultTrue;
    };

    # === Misc programs
    miscPrograms = {
      discord = defaultFalse;
      handbrake = defaultFalse; # DVD ripper
      hexchat = defaultFalse;
      obsidian = defaultFalse;
      rustdesk = defaultFalse;
      supersonic = defaultFalse;
      vlc = defaultFalse;
      xremap = defaultFalse;
      zoom = defaultFalse;
    };

    # === Office suite
    office = {
      libreoffice = defaultFalse;
      onlyoffice = defaultFalse;
    };

    # === Programming
    programming = {
      miscTools = {
        direnv = defaultTrue;
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

    # === Rclone
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

    # === Secrets
    secrets = {
      enable = defaultTrue;
      enableKeychain = defaultTrue;
    };
  };
}
