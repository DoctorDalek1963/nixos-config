{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    systemd.user = {
      services = {
        hyprsunset = {
          Unit = {
            ConditionEnvironment = "WAYLAND_DISPLAY";
            Description = "Start hyprsunset";
          };

          Service.ExecStart = "${pkgs.hyprsunset}/bin/hyprsunset --temperature 5500";
        };

        hyprsunset-stop = {
          Unit.Description = "Stop hyprsunset";
          Service.ExecStart = "/run/current-system/sw/bin/systemctl stop --user hyprsunset.service";
        };
      };

      timers = {
        hyprsunset = {
          Install.WantedBy = ["timers.target"];
          Timer.OnCalendar = ["19:00"];
        };
        hyprsunset-stop = {
          Install.WantedBy = ["timers.target"];
          Timer.OnCalendar = ["7:00"];
        };
      };
    };
  };
}
