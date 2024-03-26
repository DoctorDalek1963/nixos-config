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
      wifiPasswords = {
        enable = defaultFalse;
        groups = mkOption {
          type = types.listOf (types.enum []);
          default = [];
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
