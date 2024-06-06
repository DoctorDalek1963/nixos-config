{
  lib,
  config,
  ...
}: {
  imports = [./dconf.nix];

  config = lib.mkIf config.setup.desktopEnvironments.cinnamon.enable {};
}
