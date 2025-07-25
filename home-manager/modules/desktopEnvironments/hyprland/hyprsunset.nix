{
  pkgs,
  lib,
  osConfig,
  ...
}: {
  # TODO: Look into [sunsetr](https://github.com/psi4j/sunsetr)
  # for sunrise/sunset timing and slow, smooth transitions
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [(lib.getExe pkgs.hyprsunset)];

    xdg.configFile."hypr/hyprsunset.conf".text =
      # hyprlang
      ''
        profile {
            time = 7:00
            identity = true
        }

        profile {
            time = 19:00
            temperature = 5000
            gamma = 0.85
        }

        profile {
            time = 22:00
            temperature = 3500
            gamma = 0.75
        }
      '';
  };
}
