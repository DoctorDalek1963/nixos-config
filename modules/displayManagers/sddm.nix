{config, ...}: let
  cfg = config.setup.displayManagers.sddm;
in {
  services.displayManager.sddm = {
    inherit (cfg) enable;
    # TODO: Handle theming
  };
}
