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
  ];

  options.setup = {
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
    isLaptop = defaultFalse;

    allowUnfree = defaultFalse;

    virtualBoxGuest = defaultFalse;
    virtualBoxHost = defaultFalse;

    secrets = defaultTrue;

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
