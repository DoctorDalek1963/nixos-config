{
  lib,
  config,
  ...
}: {
  imports = [./dconf.nix];

  config = lib.mkIf config.setup.desktopEnvironments.cinnamon.enable {
    dconf.enable = true;
  };
}
