{config, ...}: let
  cfg = config.setup.displayManagers.lightdm;
in {
  services.xserver.displayManager.lightdm = {
    inherit (cfg) enable;
    # TODO: Handle theming and greeter selection
  };
}
