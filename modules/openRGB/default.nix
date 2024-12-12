{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.openRGB;
  package =
    if cfg.usePlugins
    then pkgs.openrgb-with-all-plugins
    else pkgs.openrgb;
in {
  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      inherit package;
    };

    setup.impermanence.keepDirs = ["/var/lib/OpenRGB"];
  };
}
