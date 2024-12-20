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
        background = "24274add";
        text = "cad4f5ff";
        prompt = "b9c0e0ff";
        placeholder = "8088a2ff";
        input = "cad4f5ff";
        match = "c7a0f6ff";
        selection = "6b6078ff";
        selection-text = "cad4f5ff";
        selection-match = "c7a0f6ff";
        counter = "8088a2ff";
        border = "c7a0f6ff";
      };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      bind = ["$mod, R, exec, ${config.programs.fuzzel.package}/bin/fuzzel"];
    };

    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          font = "Hack Nerd Font Mono";
          use-bold = true;
          icons-enabled = true;
          terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        };

        inherit colors;
      };
    };
  };
}
