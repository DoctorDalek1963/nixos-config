{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  inherit (lib.hm.gvariant) mkTuple mkUint32;

  cfg = config.setup.desktopEnvironments;

  terminal-emulator =
    {
      wezterm = {
        bin = "${config.programs.wezterm.package}/bin/wezterm";
        exec-arg = "start";
        desktop = "org.wezfurlong.wezterm.desktop";
      };
      terminator = {
        bin = "${pkgs.terminator}/bin/terminator";
        exec-arg = "-x";
        desktop = "terminator.desktop";
      };
    }
    .${config.setup.terminal.emulator};
in
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.gnome.enable {
    assertions = [
      {
        assertion = cfg.background-slideshow-path == null && cfg.background != null;
        message = "GNOME requires a background. It doesn't support slideshow backgrounds";
      }
    ];

    dconf = {
      enable = true;
      settings = {
        "org/gnome/desktop/applications/terminal" = {
          exec = terminal-emulator.bin;
          inherit (terminal-emulator) exec-arg;
        };

        "org/gnome/shell" = {
          favorite-apps = [
            terminal-emulator.desktop
          ]
          ++ lib.optional config.setup.librewolf.enable [ "librewolf.desktop" ];
        };

        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://${
            if builtins.isPath cfg.background then cfg.background else cfg.background.light
          }";
          picture-uri-dark = "file://${
            if builtins.isPath cfg.background then cfg.background else cfg.background.dark
          }";
          show-desktop-icons = false;
        };

        "org/gnome/desktop/input-sources" = {
          mru-sources = [
            (mkTuple [
              "xkb"
              "gb"
            ])
            (mkTuple [
              "xkb"
              "gr"
            ])
          ];
          per-window = false;
          sources = [
            (mkTuple [
              "xkb"
              "gb"
            ])
            (mkTuple [
              "xkb"
              "gr"
            ])
          ];
          xkb-options = [
            "caps:escape" # Use caps lock as escape, mostly for nvim
            "numpad:mac" # Num lock is always on
            "terminate:ctrl_alt_bksp" # Terminate the X session with ctrl + alt + backspace
            "compose:menu" # Use the menu key as the compose key
          ];
        };

        "org/gnome/desktop/interface" = {
          accent-color = "purple";
          clock-format = "12h";
          clock-show-seconds = true;
          font-hinting = "slight";
          locate-pointer = false;
          monospace-font-name = "Hack Nerd Font 10";
          show-battery-percentage = true;
          toolkit-accessibility = false;
        };

        "org/gnome/desktop/notifications" = {
          show-banners = true;
          show-in-lock-screen = false;
        };

        "org/gnome/desktop/peripherals/keyboard" = {
          numlock-state = true;
        };

        "org/gnome/desktop/peripherals/mouse" = {
          natural-scroll = false;
        };

        "org/gnome/desktop/peripherals/touchpad" = {
          edge-scrolling-enabled = false;
          natural-scroll = true;
          tap-to-click = true;
          two-finger-scrolling-enabled = true;
        };

        "org/gnome/desktop/privacy" = {
          disable-microphone = false;
          old-files-age = mkUint32 30;
          recent-files-max-age = 30;
          remove-old-temp-files = true;
          remove-old-trash-files = true;
          report-technical-problems = true;
        };

        "org/gnome/desktop/session" = {
          idle-delay = mkUint32 600; # 10 minutes
        };

        "org/gnome/desktop/sound" = {
          allow-volume-above-100-percent = true;
          event-sounds = true;
          theme-name = "Yaru";
        };

        "org/gnome/desktop/wm/preferences" = {
          button-layout = ":minimize,maximize,close";
          resize-with-right-button = false;
          workspace-names = [ ];
        };

        "org/gnome/evince/default" = {
          continuous = true;
          dual-page = false;
          dual-page-odd-left = false;
          enable-spellchecking = true;
          fullscreen = false;
          inverted-colors = false;
          show-sidebar = false;
        };

        "org/gnome/evolution-data-server/calendar" = {
          notify-window-height = 450;
          notify-window-paned-position = 250;
          notify-window-width = 675;
          notify-window-x = 90;
          notify-window-y = 80;
        };

        "org/gnome/mutter" = {
          center-new-windows = false;
          dynamic-workspaces = true;
          edge-tiling = true;
        };

        "org/gnome/nautilus/icon-view" = {
          captions = [
            "size"
            "date_modified"
            "permissions"
          ];
          default-zoom-level = "small-plus";
        };

        "org/gnome/nautilus/list-view" = {
          default-column-order = [
            "name"
            "size"
            "type"
            "owner"
            "group"
            "permissions"
            "where"
            "date_modified"
            "date_modified_with_time"
            "date_accessed"
            "recency"
            "starred"
            "detailed_type"
          ];
          default-visible-columns = [
            "name"
            "size"
            "date_modified"
            "starred"
          ];
        };

        "org/gnome/nautilus/preferences" = {
          default-folder-viewer = "icon-view";
          show-create-link = true;
          show-delete-permanently = true;
        };

        "org/gnome/nautilus/window-state" = {
          initial-size = mkTuple [
            950
            600
          ];
          maximized = false;
          sidebar-width = 200;
        };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-from = 6.25;
          night-light-schedule-to = 7.0;
          night-light-temperature = mkUint32 3240;
        };

        "org/gnome/settings-daemon/plugins/power" = {
          idle-dim = true;
          power-button-action = "nothing";
          power-saver-profile-on-low-battery = true;
          sleep-inactive-ac-type = "nothing"; # Don't automatically suspend when plugged in
          sleep-inactive-battery-timeout = 900; # 15 minutes
          sleep-inactive-battery-type = "suspend"; # Automatically suspend when on battery
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          area-screenshot-clip = [ "<Shift><Super>s" ];
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" # Open terminal
          ];
          home = [ "<Super>e" ];
          terminal = [ "<Primary><Alt>t" ];
          volume-down = [ "<Primary>Down" ];
          volume-mute = [ "AudioMute" ];
          volume-up = [ "<Primary>Up" ];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Control><Alt>t";
          command = terminal-emulator.bin;
          name = "Open Terminal";
        };

        "org/gnome/shell/weather" = {
          automatic-location = true;
          locations = [ ];
        };

        "org/gnome/system/location" = {
          enabled = true;
        };

        "org/gtk/gtk4/settings/file-chooser" = {
          date-format = "regular";
          location-mode = "path-bar";
          show-hidden = false;
          show-size-column = true;
          show-type-column = true;
          sidebar-width = 190;
          sort-column = "name";
          sort-directories-first = false;
          sort-order = "ascending";
          type-format = "category";
        };

        "org/gtk/settings/file-chooser" = {
          clock-format = "12h";
          date-format = "regular";
          location-mode = "path-bar";
          show-hidden = false;
          show-size-column = true;
          show-type-column = true;
          sidebar-width = 190;
          sort-column = "name";
          sort-directories-first = true;
          sort-order = "ascending";
          type-format = "category";
        };
      };
    };
  };
}
