{
  lib,
  config,
  ...
}: {
  imports = [./profile-pictures.nix];

  config = lib.mkIf config.setup.displayManagers.gdm.enable {
    services.xserver.displayManager.gdm.enable = true;
  };
}
