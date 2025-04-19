{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  imports = [./options.nix];

  config = lib.mkIf (cfg.enable && cfg.myspeed.enable) {
    services.myspeed.enable = true;

    setup.impermanence.keepDirs = [
      {
        directory = "${config.services.myspeed.dataDir}/data";
        user = "myspeed";
        group = "myspeed";
        mode = "755";
      }
    ];
  };
}
