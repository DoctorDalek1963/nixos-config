{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.desktopEnvironments.cinnamon.enable {
    dconf = {
      enable = true;
      settings = {};
    };
  };
}
