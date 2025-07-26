{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.gaming;
in
{
  config = lib.mkIf (cfg.enable && cfg.steam.enable) {
    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
      };

      steam = {
        enable = true;

        gamescopeSession.enable = true;
        protontricks.enable = true;

        extraCompatPackages = if cfg.steam.enableProtonGE then [ pkgs.proton-ge-bin ] else [ ];

        package = pkgs.steam.override {
          extraPkgs =
            p: with p; [
              libkrb5
              keyutils
            ];
        };
      };
    };
  };
}
