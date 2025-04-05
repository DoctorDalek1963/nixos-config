{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  colors =
    {
      "catppuccin-macchiato-mauve" = {
        low_background = "#91d7e3"; # Sky
        low_frame = "#8aadf4"; # Blue

        normal_background = "#eed49f"; # Yellow
        normal_frame = "#f5a97f"; # Peach

        critical_background = "#ee99a0"; # Maroon
        critical_frame = "#ed8796"; # Red

        light_text = "#cad3f5";
        dark_text = "#24273a";
      };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    services.dunst = {
      enable = true;
      inherit (config.gtk) iconTheme;

      settings = {
        global = {
          font = "Arimo Nerd Font 10";
          enable_posix_regex = true;

          width = "(100, 300)";
          height = "(100, 10000)";
          origin = "top-right";
          offset = "25x25"; # TODO (25.05): Update from XxY to (X, Y) syntax with v1.12

          sort = "update";

          browser = "${pkgs.xdg-utils}/bin/xdg-open";

          frame_width = config.wayland.windowManager.hyprland.settings.general.border_size;
          corner_radius = config.wayland.windowManager.hyprland.settings.decoration.rounding;
        };

        urgency_low = {
          background = colors.low_background;
          frame_color = colors.low_frame;
          foreground = colors.dark_text;
        };

        urgency_normal = {
          background = colors.normal_background;
          frame_color = colors.normal_frame;
          foreground = colors.dark_text;
        };

        urgency_critical = {
          background = colors.critical_background;
          frame_color = colors.critical_frame;
          foreground = colors.dark_text;
        };
      };
    };
  };
}
