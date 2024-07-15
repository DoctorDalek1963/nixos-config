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
  };
}
