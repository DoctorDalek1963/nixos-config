{
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup.desktopEnvironments;

  theme =
    {
      "catppuccin-macchiato-mauve" = {
        fallback_color = "rgb(36, 39, 58)";
        font_color = "rgb(202, 211, 245)";
        inner_color = "rgb(24, 25, 38)";
        outer_color = "rgb(198, 160, 246)";
        fail_color = "rgb(237, 135, 150)";
      };
    }
    .${cfg.hyprland.theme};
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.bind = [
      "$mod CTRL, L, exec, ${config.programs.hyprlock.package}/bin/hyprlock"
    ];

    programs.hyprlock = {
      enable = true;
      settings = {
        general = {
          disable_loading_bar = true;
          hide_cursor = true;
        };

        background = {
          path = "${
            if builtins.isPath cfg.background
            then cfg.background
            else cfg.background.dark
          }";
          blur_passes = 3;
          blur_size = 4;

          color = theme.fallback_color;
        };

        input-field = {
          size = "300, 50";
          position = "0, 0";

          outline_thickness = 3;
          dots_center = true;
          dots_fade_time = 100;
          fade_on_empty = true;

          placeholder_text = "";

          inherit (theme) font_color inner_color outer_color fail_color;
        };
      };
    };
  };
}
