{
  pkgs,
  lib,
  # osConfig,
  ...
}: {
  config = lib.mkIf false {
    # osConfig.setup.desktopEnvironments.hyprland.enable {

    # TODO (hyprland 0.51): Re-enable hyprsunset and look into [sunsetr](https://github.com/psi4j/sunsetr)
    # for sunrise/sunset timing and slow, smooth transitions

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
            temperature = 5000
            gamma = 85
        }

        profile {
            time = 22:00
            temperature = 3500
            gamma = 75
        }
      '';
  };
}
