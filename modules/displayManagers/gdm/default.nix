{
  lib,
  config,
  ...
}: {
  imports = [./profile-pictures.nix];

  config = lib.mkIf config.setup.displayManagers.gdm.enable {
    services.displayManager.gdm.enable = true;
  };
}
