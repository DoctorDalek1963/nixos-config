{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfgTE = config.setup.terminal.emulators;

  colors =
    {
      "catppuccin-macchiato-mauve" = {
        background = "24273add";
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
      bind = ["$mod, R, exec, $launchPrefix ${config.programs.fuzzel.package}/bin/fuzzel"];
    };

    setup.impermanence.keepFiles = [".cache/fuzzel"];

    programs.fuzzel = {
      enable = true;

      settings = {
        main = let
          hyprlandLaunchPrefix = config.wayland.windowManager.hyprland.settings."$launchPrefix";
        in {
          font = "Hack Nerd Font Mono";
          use-bold = true;
          icons-enabled = true;
          terminal =
            if cfgTE.wezterm
            then "${pkgs.wezterm}/bin/wezterm start --always-new-process"
            else if cfgTE.terminator
            then "${pkgs.terminator}/bin/terminator -x"
            else abort "Please enable a terminal emulator";

          launch-prefix = lib.mkIf (hyprlandLaunchPrefix != "") hyprlandLaunchPrefix;
        };

        inherit colors;
      };
    };
  };
}
