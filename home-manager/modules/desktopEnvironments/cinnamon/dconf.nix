{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.desktopEnvironments.cinnamon.enable {
    dconf.settings = {};
  };
}
