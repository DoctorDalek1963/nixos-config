{
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup.desktopEnvironments;
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    services.hyprpaper = {
      enable = true;
      settings = {
        preload =
          if builtins.isPath cfg.background
          then ["${cfg.background}"]
          else [
            "${cfg.background.light}"
            "${cfg.background.dark}"
          ];

        wallpaper = [
          ",${
            if builtins.isPath cfg.background
            then cfg.background
            else cfg.background.dark
          }"
        ];
      };
    };
  };
}
