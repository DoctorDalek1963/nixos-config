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

    secrets = defaultTrue;

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