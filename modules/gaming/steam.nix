{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.gaming;
  # steam-gamescope = pkgs.writeShellScriptBin "steam-gamescope" ''
  #   gamescope \
  #     --backend sdl \
  #     -w 1920 -h 1080 \
  #     --fullscreen \
  #     --prefer-vk-device 1002:747e \
  #     --steam \
  #     -- \
  #     steam -gamepadui -steamos3
  # '';
in {
  config = lib.mkIf (cfg.enable && cfg.steam.enable) {
    # environment.systemPackages = [steam-gamescope];

    programs = {
      gamescope = {
        enable = true;
        capSysNice = true;
        args = [
          "--rt"
          "--prefer-vk-device 1002:747e"
        ];
      };

      steam = {
        enable = true;
        gamescopeSession = {
          enable = true;
          # args = ["-w" "1920" "-h" "1080" "--fullscreen"];
        };

        extraCompatPackages =
          if cfg.steam.enableProtonGE
          then [pkgs.proton-ge-bin]
          else [];

        package = pkgs.steam.override {
          extraPkgs = p:
            with p; [
              libkrb5
              keyutils
            ];
        };
      };
    };
  };
}
