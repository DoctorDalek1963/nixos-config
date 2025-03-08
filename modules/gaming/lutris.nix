{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.gaming;

  lutris = pkgs.lutris.override {
    extraPkgs = p:
      with p; [
        winetricks
      ];

    extraLibraries = _p: [];
  };
in {
  config = lib.mkIf (cfg.enable && cfg.lutris) {
    environment.systemPackages = [lutris];
  };
}
