{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.desktopEnvironments.cinnamon;
in {
  config = lib.mkIf cfg.enable {
    environment.cinnamon.excludePackages = with pkgs; [
      blueberry
      warpinator
    ];

    services = {
      xserver.desktopManager.cinnamon.enable = cfg.enable;
      cinnamon.apps.enable = true;
    };
  };
}
