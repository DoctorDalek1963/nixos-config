{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.gaming;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = lib.optional cfg.emulators.ps3 pkgs.rpcs3;
  };
}
