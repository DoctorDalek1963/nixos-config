{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.gaming;
in {
  config = lib.mkIf (cfg.enable && cfg.lutris) {
    environment.systemPackages = [pkgs.lutris];
  };
}
