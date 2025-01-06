{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  system,
  ...
}: let
  cfgTE = config.setup.terminal.emulators;

  colours =
    {
      "catppuccin-macchiato-mauve" = {
        bar-background = "#181826"; # Crust
        button-background = "#363a4f"; # Surface 0
      };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home.packages = [inputs.hyprpanel.packages.${system}.hyprpanel];
    wayland.windowManager.hyprland.settings.exec-once = ["hyprpanel"];

    xdg.configFile."hyprpanel/config.json".source = pkgs.writers.writeJSON "hyprpanel-config.json" {
      "hyprpanel.restartCommand" = "hyprpanel -q; hyprpanel";
      "terminal" =
        if cfgTE.wezterm
        then "${pkgs.wezterm}/bin/wezterm start --always-new-process"
        else if cfgTE.terminator
        then "${pkgs.terminator}/bin/terminator -x"
        else abort "Please enable a terminal emulator";

      "bar.layouts" = {
        "*" = {
          left = ["workspaces" "windowtitle"];
          middle = ["clock" "notifications"];
          right =
            ["systray" "volume" "network" "bluetooth"]
            ++ (lib.optional osConfig.setup.isLaptop "battery")
            ++ ["dashboard"];
        };
      };

      "bar.workspaces.show_numbered" = true;
      "bar.workspaces.numbered_active_indicator" = "highlight";
      "bar.workspaces.workspaces" = 1;

      "bar.clock.format" = "%-I:%M:%S %p, %A %-d %B 12,0%y";
      "menus.clock.weather.enabled" = false;
      "bar.notifications.show_total" = true;
      "bar.notifications.hideCountWhenZero" = true;
      "notifications.position" = "top";

      "bar.network.showWifiInfo" = true;
      "bar.network.truncation" = false;
      "bar.launcher.autoDetectIcon" = false;
      "bar.launcher.icon" = " "; # "\uf313\u2009"

      "theme.font.size" =
        if osConfig.setup.isLaptop
        then "1rem"
        else "0.85rem";
      "theme.font.weight" = 600;
      "theme.bar.floating" = false;
      "theme.bar.transparent" = false;
      "theme.bar.buttons.enableBorders" = false;

      "theme.bar.outer_spacing" = "0.3em";
      "theme.bar.margin_top" = "0.2em";
      "theme.bar.margin_sides" = "0.2em";
      "theme.bar.margin_bottom" = "-0.2em";
      "theme.bar.dropdownGap" = "2.5em";
      "theme.bar.buttons.padding_x" = "0.5rem";
      "theme.bar.buttons.padding_y" = "0.3rem";
      "theme.bar.buttons.y_margins" = "0.4em";
      "theme.bar.buttons.spacing" = "0.3em";

      "theme.bar.background" = colours.bar-background;
      "theme.bar.buttons.background" = colours.button-background;
    };
  };
}
