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

          # Awkward workaround to let Wofi launch Steam, courtesy of https://www.reddit.com/r/linux_gaming/comments/1casb3t/comment/l0u2o70
          steam-unwrapped = pkgs.steam-unwrapped.overrideAttrs (oldAttrs: {
            postInstall = ''
              ${oldAttrs.postInstall or ""}

              substituteInPlace $out/share/applications/steam.desktop \
                --replace-fail "PrefersNonDefaultGPU=true" "PrefersNonDefaultGPU=false"
            '';
          });
        };
      };
    };
  };
}
