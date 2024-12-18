{
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.bind = [
      "$mod, R, exec, ${config.programs.wofi.package}/bin/wofi --show=drun"
    ];

    programs.wofi = {
      enable = true;
    };
  };
}
