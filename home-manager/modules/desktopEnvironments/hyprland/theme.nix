{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  gtk = rec {
    light = {
      cursor-name = "catppuccin-latte-dark-cursors";
      icon-name = "Papirus-Dark"; # We can't have multiple versions of Papirus folders
      theme-name = "catppuccin-latte-mauve-standard+rimless";
    };
    dark = {
      cursor-name = "catppuccin-macchiato-light-cursors";
      icon-name = "Papirus-Dark";
      theme-name = "catppuccin-macchiato-mauve-standard+rimless";
    };

    packages = [
      pkgs.catppuccin-cursors.latteDark
      pkgs.catppuccin-cursors.macchiatoLight

      (pkgs.catppuccin-papirus-folders.override {
        accent = "mauve";
        flavor = "macchiato";
      })

      (pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = if osConfig.setup.isLaptop then "compact" else "standard";
        tweaks = [ "rimless" ];
        variant = "latte";
      })
      (pkgs.catppuccin-gtk.override {
        accents = [ "mauve" ];
        size = if osConfig.setup.isLaptop then "compact" else "standard";
        tweaks = [ "rimless" ];
        variant = "macchiato";
      })
    ];

    file-light-2 = pkgs.writeText "gtk_2_light" ''
      gtk-cursor-theme-name = "${light.cursor-name}"
      gtk-cursor-theme-size = 24
      gtk-icon-theme-name = "${light.icon-name}"
      gtk-theme-name = "${light.theme-name}"
    '';

    file-light-3 = pkgs.writeText "gtk_3_light.ini" ''
      [Settings]
      gtk-cursor-theme-name=${light.cursor-name}
      gtk-cursor-theme-size=24
      gtk-icon-theme-name=${light.icon-name}
      gtk-theme-name=${light.theme-name}
    '';

    file-light-4 = pkgs.writeText "gtk_4_light.ini" ''
      [Settings]
      gtk-cursor-theme-name=${light.cursor-name}
      gtk-cursor-theme-size=24
      gtk-icon-theme-name=${light.icon-name}
      gtk-interface-color-scheme=3
      gtk-theme-name=${light.theme-name}
    '';

    file-dark-2 = pkgs.writeText "gtk_2_dark" ''
      gtk-cursor-theme-name = "${dark.cursor-name}"
      gtk-cursor-theme-size = 24
      gtk-icon-theme-name = "${dark.icon-name}"
      gtk-theme-name = "${dark.theme-name}"
    '';

    file-dark-3 = pkgs.writeText "gtk_3_dark.ini" ''
      [Settings]
      gtk-cursor-theme-name=${dark.cursor-name}
      gtk-cursor-theme-size=24
      gtk-icon-theme-name=${dark.icon-name}
      gtk-theme-name=${dark.theme-name}
    '';

    file-dark-4 = pkgs.writeText "gtk_4_dark.ini" ''
      [Settings]
      gtk-cursor-theme-name=${dark.cursor-name}
      gtk-cursor-theme-size=24
      gtk-icon-theme-name=${dark.icon-name}
      gtk-interface-color-scheme=2
      gtk-theme-name=${dark.theme-name}
    '';

  };

  theme-switcher = pkgs.writeShellApplication {
    name = "theme-switcher";
    runtimeInputs = [ pkgs.sunwait ];

    # Script inspired by https://dominic-boettger.com/blog/auto-dark-mode-linux-sunrise-sunset/
    text = ''
      is_daytime() {
          # Location is London, same as sunsetr
          r="$(sunwait poll civil 51.508415N 0.125533W 2> /dev/null)"
          [[ "$r" == "DAY" ]]
      }

      set_light_theme() {
          mkdir -p ~/.config/gtk-3.0
          mkdir -p ~/.config/gtk-4.0

          ln -sf "${gtk.file-light-2}" ~/.gtkrc-2.0
          ln -sf "${gtk.file-light-3}" ~/.config/gtk-3.0/settings.ini
          ln -sf "${gtk.file-light-4}" ~/.config/gtk-4.0/settings.ini

          dconf write /org/gnome/desktop/interface/color-scheme "'prefer-light'"

          # TODO: Wezterm
      }

      set_dark_theme() {
          mkdir -p ~/.config/gtk-3.0
          mkdir -p ~/.config/gtk-4.0

          ln -sf "${gtk.file-dark-2}" ~/.gtkrc-2.0
          ln -sf "${gtk.file-dark-3}" ~/.config/gtk-3.0/settings.ini
          ln -sf "${gtk.file-dark-4}" ~/.config/gtk-4.0/settings.ini

          dconf write /org/gnome/desktop/interface/color-scheme "'prefer-dark'"

          # TODO: Wezterm
      }

      # TODO: Lock file or something to detect manual mode so that auto doesn't override it
      case "$1" in
          light)
              set_light_theme
              ;;
          dark)
              set_dark_theme
              ;;
          auto)
              if is_daytime; then set_light_theme; else set_dark_theme; fi
              ;;
      esac
    '';
  };

  theme-switcher-wofi = pkgs.writeShellApplication {
    name = "theme-switcher-wofi";
    runtimeInputs = [
      theme-switcher
      config.programs.wofi.package
    ];

    text = ''
      choice="$(printf 'auto\nlight\ndark' | wofi --show=dmenu --cache-file=/dev/null)"
      theme-switcher "$choice"
    '';
  };
in
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    # TODO: Systemd service and timer to auto switch

    home.packages = gtk.packages;

    wayland.windowManager.hyprland.settings.bind = [
      "$mod, D, exec, ${lib.getExe theme-switcher-wofi}"
    ];
  };
}
