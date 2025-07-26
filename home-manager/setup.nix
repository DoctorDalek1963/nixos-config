{
  lib,
  config,
  osConfig,
  inputs,
  ...
}:
let
  inherit (lib) mkOption types;
  inherit (config.consts)
    valid-gnome-themes
    valid-hyprland-themes
    valid-terminal-themes
    valid-shells
    ;

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
    ./modules/impermanence
    ./modules/librewolf
    ./modules/maths
    ./modules/misc
    ./modules/office
    ./modules/programming
    ./modules/rclone
    ./modules/secrets
  ];
  other-modules = [
    inputs.nix-index-database.homeModules.nix-index
    inputs.sops-nix.homeManagerModules.sops
    inputs.xremap.homeManagerModules.default
  ];
in
{
  imports = file-modules ++ other-modules;

  options.setup = {
    username = mkOption {
      type = types.nonEmptyStr;
    };

    # === Shell and terminal stuff

    terminal = {
      shells = {
        bash = defaultTrue;
      };
      defaultShell = mkOption {
        default = "bash";
        type = types.enum valid-shells;
      };
      shellAliases = mkOption {
        default = { };
        type = types.attrsOf types.nonEmptyStr;
      };

      emulator = mkOption {
        default = "wezterm";
        type = types.enum [
          "terminator"
          "wezterm"
        ];
      };

      multiplexer = mkOption {
        default = "zellij";
        type = types.enum [
          "none"
          "zellij"
        ];
      };

      theme = mkOption {
        type = types.enum valid-terminal-themes;
        default = "catppuccin-macchiato";
      };

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
        direnv = defaultTrue;
        fd = defaultTrue;
        fzf = defaultTrue;
        git = defaultTrue;
        git-all = defaultTrue;
        gh = defaultTrue;
        nvim = mkOption {
          type = types.enum [
            "stock"
            "tiny"
            "small"
            "medium"
            "full"
          ];
          default = "medium";
        };
        lazygit = defaultTrue;
        ripgrep = defaultTrue;
        yazi = defaultTrue;
        zoxide = defaultTrue;

        # Just install the packages
        eza = defaultTrue;
        fastfetch = defaultTrue;
        hyperfine = defaultTrue;
        just = defaultTrue;
        sad = defaultTrue;
        sd = defaultTrue;
        tldr = defaultTrue;
        yt-dlp = defaultFalse;
      };
    };

    # === Desktop stuff
    desktopEnvironments = {
      # Either one path, a light/dark pair of paths, or a slideshow path
      background = mkOption {
        type = types.nullOr (
          types.either types.path (
            types.submodule {
              options = {
                light = mkOption { type = types.path; };
                dark = mkOption { type = types.path; };
              };
            }
          )
        );
        default = null;
      };
      background-slideshow-path = mkOption {
        type = types.nullOr types.nonEmptyStr;
        default = null;
      };

      cinnamon = {
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
        enableExtensions = defaultTrue;
        theme = mkOption {
          type = types.enum valid-gnome-themes;
        };
      };
      hyprland = {
        theme = mkOption {
          type = types.enum valid-hyprland-themes;
        };
        borderStyle = {
          rainbow = defaultTrue;
          animateGradientAngle = {
            enable = mkOption {
              type = types.bool;
              default = config.setup.desktopEnvironments.hyprland.borderStyle.rainbow && !osConfig.setup.isLaptop;
            };
            speedSecs = mkOption {
              type = types.int;
              default = 10;
            };
          };
        };
      };
    };

    # === LibreWolf
    librewolf = {
      enable = defaultFalse;
      minimal = defaultFalse;
      enableExtensions = defaultTrue;
    };

    # === Fonts
    fonts = {
      hackNerdFont = defaultTrue;
      microsoftFonts = defaultFalse;
    };

    # === Impermanence
    impermanence =
      let
        keepList = mkOption {
          type = types.listOf (types.either types.nonEmptyStr types.attrs);
          default = [ ];
        };
      in
      {
        keepDirs = keepList;
        keepFiles = keepList;
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

    # === Misc stuff
    misc = {
      programs = {
        anki = defaultFalse;
        discord = defaultFalse;
        evince = defaultFalse;
        feishin = defaultFalse; # Subsonic music player
        handbrake = defaultFalse; # DVD ripper
        hexchat = defaultFalse;
        loupe = mkOption {
          default = osConfig.setup.isGraphical;
        };
        ms-teams = defaultFalse;
        obsidian = defaultFalse;
        rustdesk = defaultFalse;
        vlc = defaultFalse;
        xremap = defaultFalse;
        zathura = mkOption {
          default = osConfig.setup.isGraphical;
        };
        zoom = defaultFalse;
      };

      services = {
        easyeffects = defaultFalse;
        safeeyes = defaultFalse;
      };
    };

    # === Office suite
    office = {
      libreoffice = defaultFalse;
      onlyoffice = defaultFalse;
    };

    # === Programming
    programming = {
      haskell = defaultFalse;
      julia = defaultFalse;
      python = defaultFalse;
      rust = defaultFalse;

      nix = defaultTrue;
      jetbrains = defaultFalse;

      misc = defaultFalse;
    };

    # === Rclone
    rclone = {
      enable = defaultFalse;
      automounts = mkOption {
        default = [ ];
        type = types.listOf (
          types.submodule {
            options = {
              remote = mkOption {
                type = types.nonEmptyStr;
                description = "The name of the remote server to mount.";
              };
              remotePath = mkOption {
                type = types.str;
                default = "";
                description = "The path on the remote to mount, if any.";
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
          }
        );
      };
    };

    # === Secrets
    secrets = {
      enable = defaultTrue;
      enableKeychain = defaultTrue;
    };
  };
}
