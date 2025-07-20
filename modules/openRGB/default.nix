{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.openRGB;

  with-all-plugins = import ./with-all-plugins.nix {inherit pkgs;};

  package =
    if cfg.usePlugins
    then with-all-plugins
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
