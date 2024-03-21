{config, ...}: let
  cfg = config.setup.displayManagers.sddm;
in {
  services.xserver.displayManager.sddm = {
    inherit (cfg) enable;
    # TODO: Handle theming
  };
}
