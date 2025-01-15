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

        purple = "#c6a0f6";
        pink = "#f5bde6";
        light-red = "#ee99a0";
        yellow = "#eed49f";
        teal = "#8bd5ca";
        light-blue = "#7dc4e4";
        blue = "#8aadf4";
        lavender = "#b7bdf8";
      };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};

  theme-json = {
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
    "theme.bar.buttons.icon_background" = colours.button-background;

    "theme.bar.buttons.dashboard.background" = colours.button-background;
    "theme.bar.buttons.dashboard.icon" = colours.yellow;
    "theme.bar.buttons.dashboard.border" = colours.yellow;

    "theme.bar.buttons.workspaces.background" = colours.button-background;
    "theme.bar.buttons.workspaces.hover" = colours.pink;
    "theme.bar.buttons.workspaces.active" = colours.pink;
    "theme.bar.buttons.workspaces.available" = colours.light-blue;
    "theme.bar.buttons.workspaces.occupied" = colours.yellow;
    "theme.bar.buttons.workspaces.numbered_active_highlighted_text_color" = colours.button-background;
    "theme.bar.buttons.workspaces.numbered_active_underline_color" = colours.pink;
    "theme.bar.buttons.workspaces.border" = colours.pink;

    "theme.bar.buttons.windowtitle.background" = colours.button-background;
    "theme.bar.buttons.windowtitle.text" = colours.pink;
    "theme.bar.buttons.windowtitle.icon" = colours.pink;
    "theme.bar.buttons.windowtitle.border" = colours.pink;

    "theme.bar.buttons.media.background" = colours.button-background;
    "theme.bar.buttons.media.text" = colours.light-blue;
    "theme.bar.buttons.media.icon" = colours.light-blue;
    "theme.bar.buttons.media.border" = colours.light-blue;

    "theme.bar.buttons.volume.background" = colours.button-background;
    "theme.bar.buttons.volume.text" = colours.light-red;
    "theme.bar.buttons.volume.icon" = colours.light-red;
    "theme.bar.buttons.volume.border" = colours.light-red;

    "theme.bar.buttons.clock.background" = colours.button-background;
    "theme.bar.buttons.clock.text" = colours.pink;
    "theme.bar.buttons.clock.icon" = colours.pink;
    "theme.bar.buttons.clock.border" = colours.pink;

    "theme.bar.buttons.notifications.background" = colours.button-background;
    "theme.bar.buttons.notifications.text" = colours.light-blue;
    "theme.bar.buttons.notifications.icon" = colours.light-blue;
    "theme.bar.buttons.notifications.border" = colours.light-blue;

    "theme.bar.buttons.battery.background" = colours.button-background;
    "theme.bar.buttons.battery.text" = colours.yellow;
    "theme.bar.buttons.battery.icon" = colours.yellow;
    "theme.bar.buttons.battery.border" = colours.yellow;

    "theme.bar.buttons.network.background" = colours.button-background;
    "theme.bar.buttons.network.text" = colours.purple;
    "theme.bar.buttons.network.icon" = colours.purple;
    "theme.bar.buttons.network.border" = colours.purple;

    "theme.bar.buttons.bluetooth.background" = colours.button-background;
    "theme.bar.buttons.bluetooth.text" = colours.teal;
    "theme.bar.buttons.bluetooth.icon" = colours.teal;
    "theme.bar.buttons.bluetooth.border" = colours.teal;

    "theme.bar.buttons.systray.background" = colours.button-background;
    "theme.bar.menus.menu.systray.dropdownmenu.background" = colours.button-background;
  };
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home.packages = [inputs.hyprpanel.packages.${system}.hyprpanel];
    wayland.windowManager.hyprland.settings.exec-once = ["hyprpanel"];

    xdg.configFile."hyprpanel/config.json".source = pkgs.writers.writeJSON "hyprpanel-config.json" ({
        "hyprpanel.restartCommand" = "hyprpanel -q; hyprpanel";
        "terminal" =
          if cfgTE.wezterm
          then "${config.programs.wezterm.package}/bin/wezterm start --always-new-process"
          else if cfgTE.terminator
          then "${pkgs.terminator}/bin/terminator -x"
          else abort "Please enable a terminal emulator";

        "bar.layouts" = {
          "*" = {
            left = ["workspaces" "windowtitle"];
            middle = ["clock" "notifications"];
            right =
              ["systray" "volume"]
              ++ (lib.optional osConfig.setup.isLaptop "battery")
              ++ ["network" "bluetooth" "dashboard"];
          };
        };

        "bar.workspaces.show_numbered" = true;
        "bar.workspaces.numbered_active_indicator" = "highlight";
        "bar.workspaces.workspaces" = 1;
        "bar.workspaces.ignored" = -99; # Special workspace

        "bar.clock.format" = "%-I:%M:%S %p, %A %-d %B 12,0%y";
        "menus.clock.weather.enabled" = false;
        "bar.notifications.show_total" = true;
        "bar.notifications.hideCountWhenZero" = true;
        "notifications.position" = "top";

        "bar.network.showWifiInfo" = true;
        "bar.network.truncation" = false;
        "bar.launcher.autoDetectIcon" = false;
        "bar.launcher.icon" = " "; # "\uf313\u2009"
      }
      // theme-json);
  };
}
