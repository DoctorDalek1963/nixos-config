{
  lib,
  config,
  ...
}: {
  imports = [./dconf.nix ./menuIcon.nix ./themes.nix];

  config = lib.mkIf config.setup.desktopEnvironments.cinnamon.enable {};
}
