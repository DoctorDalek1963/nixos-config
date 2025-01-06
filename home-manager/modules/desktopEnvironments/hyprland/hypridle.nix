{
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${config.services.hypridle.package}/bin/hypridle"
    ];

    services.hypridle = {
      enable = true;
      settings = let
        hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
        hyprlock = "${config.programs.hyprlock.package}/bin/hyprlock";
      in {
        general = {
          after_sleep_cmd = "${hyprctl} dispatch dpms on";
          lock_cmd = "${hyprlock}";
          ignore_dbus_inhibit = false;
          ignore_systemd_inhibit = false;
        };

        listener = let
          lock-timeout = 900; # 15 minutes
        in [
          {
            timeout = lock-timeout;
            on-timeout = "${hyprlock}";
          }
          {
            timeout = lock-timeout + 15;
            on-timeout = "${hyprctl} dispatch dpms off";
            on-resume = "${hyprctl} dispatch dpms on";
          }
        ];
      };
    };
  };
}
