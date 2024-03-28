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

    ./modules/desktopEnvironments/default.nix
    ./modules/displayManagers/default.nix
    ./modules/pam/default.nix
    ./modules/secrets/default.nix
    ./modules/virtualBox/default.nix
    ./modules/uinput/default.nix
    ./modules/openRGB/default.nix
  ];

  options.setup = {
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
    isLaptop = defaultFalse;

    enablePrinting = defaultFalse;
    enableSsh = defaultTrue;

    allowUnfree = defaultFalse;

    virtualBoxGuest = defaultFalse;
    virtualBoxHost = defaultFalse;

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

    pamShortenFailDelay = {
      enable = defaultTrue;
      microseconds = mkOption {
        type = types.ints.unsigned;
        default = 150000; # 150 ms
      };
    };

    uinput = {
      enable = defaultFalse;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
      };
    };

    openRGB = defaultFalse;

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
  };
}
