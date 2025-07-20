{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.openRGB;

  with-all-plugins = import ./with-all-plugins.nix {inherit pkgs;};

  package =
    if cfg.usePlugins
    then with-all-plugins
    else pkgs.openrgb;
in {
  config = lib.mkIf cfg.enable {
    services.hardware.openrgb = {
      enable = true;
      inherit package;
    };

    setup.impermanence.keepDirs = ["/var/lib/OpenRGB"];

    systemd = lib.mkIf cfg.simpleDaytimeRainbow {
      services = {
        openrgb-start-rainbow.serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe package} --mode rainbow";
        };

        openrgb-lights-off.serviceConfig = {
          Type = "oneshot";
          ExecStart = "${lib.getExe package} --mode off";
        };
      };

      timers = {
        openrgb-start-rainbow = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "07:30";
            Unit = "openrgb-start-rainbow.service";
          };
        };
        openrgb-lights-off = {
          wantedBy = ["timers.target"];
          timerConfig = {
            OnCalendar = "22:30";
            Unit = "openrgb-lights-off.service";
          };
        };
      };
    };
  };
}
