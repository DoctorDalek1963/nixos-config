{
  pkgs,
  lib,
  # osConfig,
  ...
}: {
  config = lib.mkIf false {
    # osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [(lib.getExe pkgs.hyprsunset)];

    xdg.configFile."hypr/hyprsunset.config".text =
      # hyprlang
      ''
        profile {
            time = 7:00
            identity = true
        }

        profile {
            time = 19:00
            temperature = 5500
            gamma = 0.8
        }

        profile {
            time = 22:00
            temperature = 5000
            gamma = 0.7
        }
      '';
  };
}
