{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.desktopEnvironments.androidTv;

  waydroid = pkgs.waydroid-nftables;

  sessionFile =
    (pkgs.writeTextDir "share/wayland-sessions/android-tv.desktop" ''
      [Desktop Entry]
      Name=Android TV
      Comment=Android TV in Waydroid
      Exec=${lib.getExe pkgs.cage} ${lib.getExe waydroid} show-full-ui
      Type=Application
    '').overrideAttrs
      (_: {
        passthru.providedSessions = [ "android-tv" ];
      });
in
{
  config = lib.mkIf cfg.enable (
    lib.mkMerge [
      {
        virtualisation.waydroid = {
          enable = true;
          package = waydroid;
        };

        boot.kernelPatches = [
          {
            name = "waydroid-add-dmabuf";
            patch = null;
            structuredExtraConfig = with lib.kernel; {
              DMABUF_HEAPS = yes;
              DMABUF_HEAPS_SYSTEM = yes;
            };
          }
        ];

        setup.impermanence.keepDirs = [
          "/var/lib/waydroid"
        ];
      }
      (lib.mkIf cfg.asSession {
        services.displayManager.sessionPackages = [ sessionFile ];
      })
      (lib.mkIf (!cfg.asSession) {
        services.cage = {
          enable = true;
          program = "${lib.getExe waydroid} show-full-ui";
        };
      })
    ]
  );
}
