{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.gaming;
in {
  config = lib.mkIf (cfg.enable && cfg.steam.enable) {
    programs.steam = {
      enable = true;
      extraCompatPackages =
        if cfg.steam.enableProtonGE
        then [pkgs.proton-ge-bin]
        else [];
    };
  };
}
