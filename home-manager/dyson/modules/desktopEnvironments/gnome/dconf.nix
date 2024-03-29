{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (config.setup.desktopEnvironments.gnome) background;
  light-path =
    if builtins.isPath background
    then background
    else background.light;
  dark-path =
    if builtins.isPath background
    then background
    else background.dark;
in
  with lib.hm.gvariant; {
    config = lib.mkIf config.setup.desktopEnvironments.gnome.enable {
      dconf.settings = {
        "org/gnome/desktop/applications/terminal" = {
          exec = "${pkgs.terminator}/bin/terminator";
          exec-arg = "-x";
        };

        "org/gnome/shell" = {
          favorite-apps = ["terminator.desktop" "firefox.desktop"];
        };

        "org/gnome/desktop/background" = {
          color-shading-type = "solid";
          picture-options = "zoom";
          picture-uri = "file://${light-path}";
          picture-uri-dark = "file://${dark-path}";
          show-desktop-icons = false;
        };

        "org/gnome/desktop/input-sources" = {
          mru-sources = [(mkTuple ["xkb" "gb"]) (mkTuple ["xkb" "gr"])];
          per-window = false;
          sources = [(mkTuple ["xkb" "gb"]) (mkTuple ["xkb" "gr"])];
          xkb-options = [
            "caps:escape" # Use caps lock as escape, mostly for vim
            "numpad:mac" # Num lock is always on
            "terminate:ctrl_alt_bksp" # Terminate the X session with ctrl + alt + backspace
            "compose:menu" # Use the menu key as the compose key
          ];
        };

        "org/gnome/desktop/interface" = {
          clock-format = "12h";
          clock-show-seconds = true;
          color-scheme = "prefer-dark";
          cursor-theme = "Vimix-white-cursors";
          font-hinting = "slight";
          icon-theme = "Vimix-Amethyst-dark";
          locate-pointer = false;
          monospace-font-name = "Hack Nerd Font 10";
          toolkit-accessibility = false;
        };

        "org/gnome/desktop/notifications" = {
          show-banners = true;
          show-in-lock-screen = false;
        };

        "org/gnome/desktop/peripherals/keyboard" = {
          numlock-state = true;
        };

        "org/gnome/desktop/peripherals/touchpad" = {
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

        "org/gnome/desktop/screensaver" = {
          color-shading-type = "solid";
          lock-delay = mkUint32 0;
          picture-options = "zoom";
          picture-uri = "file:///home/dyson/.local/share/backgrounds/2022-04-02-19-18-50-fossa-purple.jpeg";
          primary-color = "#000000000000";
          secondary-color = "#000000000000";
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
          num-workspaces = 4;
          resize-with-right-button = false;
          workspace-names = [];
        };

        "org/gnome/eog/fullscreen" = {
          seconds = 3;
        };

        "org/gnome/eog/plugins" = {
          active-plugins = ["statusbar-date" "fullscreen"];
        };

        "org/gnome/eog/ui" = {
          image-gallery = false;
          sidebar = false;
          statusbar = true;
        };

        "org/gnome/eog/view" = {
          background-color = "rgb(0,0,0)";
          extrapolate = false;
          interpolate = false;
          use-background-color = true;
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

        "org/gnome/mutter" = {
          center-new-windows = false;
          dynamic-workspaces = true;
          edge-tiling = true;
        };

        # TODO: Set nemo as default file browser
        # "org/gnome/nautilus/icon-view" = {
        #   captions = ["size" "type" "none"];
        #   default-zoom-level = "small";
        # };
        #
        # "org/gnome/nautilus/list-view" = {
        #   default-column-order = ["name" "size" "type" "owner" "group" "permissions" "where" "date_modified" "date_modified_with_time" "date_accessed" "recency" "starred" "detailed_type"];
        #   default-visible-columns = ["name" "size" "date_modified" "starred"];
        #   use-tree-view = false;
        # };
        #
        # "org/gnome/nautilus/preferences" = {
        #   default-folder-viewer = "icon-view";
        #   fts-enabled = false;
        #   search-filter-time-type = "last_modified";
        #   search-view = "list-view";
        #   show-create-link = true;
        # };
        #
        # "org/gnome/nautilus/window-state" = {
        #   initial-size = mkTuple [900 600];
        #   maximized = false;
        #   sidebar-width = 200;
        # };

        "org/gnome/settings-daemon/plugins/color" = {
          night-light-enabled = true;
          night-light-schedule-from = 6.25;
          night-light-schedule-to = 7.0;
          night-light-temperature = mkUint32 3240;
        };

        "org/gnome/settings-daemon/plugins/media-keys" = {
          area-screenshot-clip = ["<Shift><Super>s"];
          custom-keybindings = [
            "/org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0/" # Terminator
          ];
          home = ["<Super>e"];
          terminal = ["<Primary><Alt>t"];
          volume-down = ["<Primary>Down"];
          volume-mute = ["AudioMute"];
          volume-up = ["<Primary>Up"];
        };

        "org/gnome/settings-daemon/plugins/media-keys/custom-keybindings/custom0" = {
          binding = "<Control><Alt>t";
          command = "${pkgs.terminator}/bin/terminator";
          name = "Open Terminator";
        };

        "org/gnome/shell/weather" = {
          automatic-location = true;
          locations = [];
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

        "org/nemo/desktop" = {
          show-desktop-icons = false;
        };

        "org/nemo/icon-view" = {
          captions = ["size" "date_modified" "octal_permissions"];
          default-zoom-level = "small";
        };

        "org/nemo/plugins" = {
          disabled-actions = [
            "change-background.nemo_action"
            "set-as-background.nemo_action"
            "add-desklets.nemo_action"
          ];
        };

        "org/nemo/preferences" = {
          bulk-rename-tool = "bulky";
          click-double-parent-folder = true;
          date-format = "informal";
          inherit-folder-viewer = false;
          quick-renames-with-pause-in-between = true;
          show-advanced-permissions = true;
          show-hidden-files = false;
          show-location-entry = false;
          tooltips-in-icon-view = true;
          tooltips-show-mod-date = true;
        };

        "org/nemo/preferences/menu-config" = {
          selection-menu-make-link = true;
        };

        "org/nemo/window-state" = {
          maximized = false;
          my-computer-expanded = true;
          side-pane-view = "places";
          sidebar-bookmark-breakpoint = 9;
          sidebar-width = 180;
          start-with-sidebar = true;
        };
      };
    };
  }
