{lib, ...}:
with lib; let
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

    ./modules/androidTools/default.nix
    ./modules/desktopEnvironments/default.nix
    ./modules/displayManagers/default.nix
    ./modules/gaming/default.nix
    ./modules/openRGB/default.nix
    ./modules/pam/default.nix
    ./modules/secrets/default.nix
    ./modules/uinput/default.nix
    ./modules/virtualBox/default.nix
  ];

  options.setup = {
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
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
        users = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = ["dyson"];
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
    };

    # === Input
    # We need uinput for xremap and weylus
    uinput = {
      enable = defaultFalse;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
      };
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
