{
  lib,
  config,
  ...
}: {
  imports = [./dconf.nix ./menuIcon.nix];

  config = lib.mkIf config.setup.desktopEnvironments.cinnamon.enable {};
}
