{
  lib,
  config,
  osConfig,
  ...
}:
let
  theme =
    {
      "catppuccin-macchiato-mauve" = {
        background = "rgba(36, 39, 58, 0.85)";
        border = "#c7a0f6";
      };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};
in
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      bind = [ "$mod, R, exec, ${lib.getExe config.programs.wofi.package} --show=drun" ];
    };

    setup.impermanence.keepFiles = [ ".cache/wofi-drun" ];

    programs.wofi = {
      enable = true;

      settings = {
        allow_images = true;
        insensitive = true;
        matching = "fuzzy";
        term = config.wayland.windowManager.hyprland.settings."$terminal";

        normal_window = true;

        width = "25%";
        height = "35%";
      };

      style =
        # CSS
        ''
          window {
            /* border: 2px solid ${theme.border}; */
            /* border-radius: 5px; */
            background-color: ${theme.background};
            font-family: "Hack Nerd Font Mono";
          }

          #input {
            margin: 0px;
            border-bottom: 1px solid ${theme.border};
            border-radius: 0px;
            background-color: rgba(0, 0, 0, 0.0);
          }

          #inner-box {
            padding: 8px;
          }
        '';
    };
  };
}
