{lib, ...}: let
  inherit (lib) mkOption types;

  defaultTrue = mkOption {
    default = true;
    type = types.bool;
  };
  defaultFalse = mkOption {
    default = false;
    type = types.bool;
  };
in {
  imports = [
    ./modules/core.nix

    ./modules/graphical
    ./modules/laptop

    ./modules/androidTools
    ./modules/desktopEnvironments
    ./modules/displayManagers
    ./modules/development
    ./modules/gaming
    ./modules/openRGB
    ./modules/homeServer
    ./modules/pam
    ./modules/secrets
    ./modules/uinput
    ./modules/users
    ./modules/virtualBox
  ];

  options.setup = {
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
    isGraphical = defaultTrue;
    isLaptop = defaultFalse;

    # === Basic system config
    enablePrinting = defaultFalse;
    enableSsh = defaultTrue;

    allowUnfree = defaultFalse;

    # === Android dev
    androidTools = {
      enable = defaultFalse;
      droidcam = defaultTrue;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
      };
    };

    # === Desktop stuff
    profilePictures = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf types.path;
      };
      default = {};
    };

    desktopEnvironments = {
      gnome = {
        enable = defaultFalse;
        minimal = defaultTrue;
      };
    };

    displayManagers = {
      gdm = {
        enable = defaultFalse;
      };
      sddm = {
        enable = defaultFalse;
        # TODO: Handle theming
      };
    };

    # === Development
    binfmt = {
      aarch64 = defaultFalse;
    };

    # === Gaming
    gaming = {
      enable = defaultFalse;
      steam = {
        enable = defaultTrue;
        enableProtonGE = defaultTrue;
      };
      lutris = defaultTrue;
    };

    openRGB = {
      enable = defaultFalse;
      usePlugins = defaultTrue;
    };

    # === Home server
    homeServer = {
      domainName = mkOption {
        type = types.nonEmptyStr;
      };

      homeAutomation = {};
      mediaServer = {};
      personalProjects = {
        enable = defaultFalse;
        tictactoe = defaultTrue;
        winter-wonderlights = defaultTrue;
        wordle = defaultTrue;
      };
    };

    # === Passwords
    pamShortenFailDelay = {
      enable = defaultTrue;
      microseconds = mkOption {
        type = types.ints.unsigned;
        default = 150000; # 150 ms
      };
    };

    # === Secrets
    secrets = {
      enable = defaultTrue;
      userPasswords = {
        enable = defaultTrue;

        # Note that enabling any of these DOES NOT enable the user. Use
        # `setup.users` to enable users.
        users = {
          dyson = defaultTrue;
          pi = defaultTrue;
        };
      };
      networking = {
        enable = defaultFalse;
        simpleWifiNetworkNames = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = ["HOME"];
          description = ''The names of the simple WiFi networks to use. Each name here should have entries of the form "<name>_SSID" and "<name>_PSK" in the secret environment.env file.'';
        };
      };
      vpn = {
        enable = defaultFalse;
        vpns = mkOption {
          type = types.listOf (types.submodule {
            options = {
              vpnName = mkOption {
                type = types.nonEmptyStr;
              };
              users = mkOption {
                type = types.listOf types.nonEmptyStr;
              };
            };
          });
          default = [
            {
              vpnName = "gb-hotspotshield";
              users = ["dyson"];
            }
          ];
        };
      };
      tailscale.enable = defaultTrue;
      cachix.enable = defaultTrue;
    };

    # === uinput
    # We need uinput for xremap and weylus
    uinput = {
      enable = defaultFalse;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
      };
    };

    # === Users
    users = {
      dyson = defaultTrue;
      pi = defaultFalse;
    };

    # === VirtualBox
    virtualBox = {
      guest.enable = defaultFalse;
      host = {
        enable = defaultFalse;
        users = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = [];
        };
      };
    };
  };
}
