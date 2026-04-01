{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    home = {
      sessionVariables.QT_QPA_PLATFORMTHEME = "qt6ct";

      packages = [
        pkgs.adw-gtk3
        pkgs.nwg-look

        pkgs.libsForQt5.qt5ct
        pkgs.kdePackages.qt6ct
      ];
    };

    xdg.configFile."noctalia/colorschemes/Catppuccin Macchiato/Catppuccin Macchiato.json".text =
      builtins.toJSON
        {
          dark = {
            mError = "#ed8796"; # Red
            mOnError = "#181926"; # Crust

            mHover = "#8bd5ca"; # Teal
            mOnHover = "#181926"; # Crust

            mPrimary = "#c6a0f6"; # Mauve
            mOnPrimary = "#181926"; # Crust

            mSecondary = "#f5a97f"; # Peach
            mOnSecondary = "#181926"; # Crust

            mTertiary = "#8bd5ca"; # Teal
            mOnTertiary = "#181926"; # Crust

            mSurface = "#24273a"; # Base
            mOnSurface = "#cad3f5"; # Text

            mSurfaceVariant = "#363a4f"; # Surface 0
            mOnSurfaceVariant = "#b7bdf8"; # Lavender

            mOutline = "#494d64"; # Surface 1

            mShadow = "#181926"; # Crust

            terminal = {
              cursor = "#f4dbd6"; # Rosewater
              cursorText = "#24273a"; # Base

              background = "#24273a"; # Base
              foreground = "#cad3f5"; # Text

              selectionBg = "#5b6078"; # Surface 2
              selectionFg = "#cad3f5"; # Text

              # Taken from Wezterm Catppuccin theme
              normal = {
                black = "#494d64"; # Surface 1
                red = "#ed8796"; # Red
                green = "#a6da95"; # Green
                yellow = "#eed49f"; # Yellow
                blue = "#8aadf4"; # Blue
                magenta = "#f5bde6"; # Pink
                cyan = "#8bd5ca"; # Teal
                white = "#b8c0e0"; # Subtext 1
              };

              bright = {
                black = "#5b6078"; # Surface 2
                red = "#ed8796"; # Red
                green = "#a6da95"; # Green
                yellow = "#eed49f"; # Yellow
                blue = "#8aadf4"; # Blue
                magenta = "#f5bde6"; # Pink
                cyan = "#8bd5ca"; # Teal
                white = "#a5adcb"; # Subtext 0
              };
            };
          };

          light = {
            mError = "#d20f39"; # Red
            mOnError = "#dce0e8"; # Crust

            mHover = "#40a02b"; # Green
            mOnHover = "#eff1f5"; # Base

            mPrimary = "#8839ef"; # Mauve
            mOnPrimary = "#eff1f5"; # Base

            mSecondary = "#fe640b"; # Peach
            mOnSecondary = "#eff1f5"; # Base

            mTertiary = "#40a02b"; # Green
            mOnTertiary = "#eff1f5"; # Base

            mSurface = "#eff1f5"; # Base
            mOnSurface = "#4c4f69"; # Text

            mSurfaceVariant = "#ccd0da"; # Surface 0
            mOnSurfaceVariant = "#6c6f85"; # Subtext 0

            mOutline = "#acb0be"; # Surface 2

            mShadow = "#dce0e8"; # Crust

            terminal = {
              cursor = "#dc8a78"; # Rosewater
              cursorText = "#eff1f5"; # Base

              background = "#eff1f5"; # Base
              foreground = "#4c4f69"; # Text

              selectionBg = "#acb0be"; # Surface 2
              selectionFg = "#4c4f69"; # Text

              # Taken from Wezterm Catppuccin theme
              normal = {
                black = "#bcc0cc"; # Surface 1
                red = "#d20f39"; # Red
                green = "#40a02b"; # Green
                yellow = "#df8e1d"; # Yellow
                blue = "#1e66f5"; # Blue
                magenta = "#ea76cb"; # Pink
                cyan = "#179299"; # Teal
                white = "#5c5f77"; # Subtext 1
              };

              bright = {
                black = "#acb0be"; # Surface 2
                red = "#d20f39"; # Red
                green = "#40a02b"; # Green
                yellow = "#df8e1d"; # Yellow
                blue = "#1e66f5"; # Blue
                magenta = "#ea76cb"; # Pink
                cyan = "#179299"; # Teal
                white = "#6c6f85"; # Subtext 0
              };
            };
          };
        };

    qt = {
      qt5ctSettings.Appearance = {
        color_scheme_path = "${config.home.homeDirectory}/.config/qt5ct/colors/noctalia.conf";
        custom_palette = true;
      };
      qt6ctSettings.Appearance = {
        color_scheme_path = "${config.home.homeDirectory}/.config/qt6ct/colors/noctalia.conf";
        custom_palette = true;
      };
    };

    programs.noctalia-shell.settings = {
      colorSchemes = {
        useWallpaperColors = false;
        generationMethod = "tonal-spot";

        schedulingMode = "location";
        predefinedScheme = "Catppuccin Macchiato";
      };

      templates = {
        enableUserTheming = true;

        activeTemplates =
          map
            (id: {
              inherit id;
              enabled = true;
            })
            (
              [
                "gtk"
                "qt"
                # "btop"
                # "yazi"
                # "zathura"
              ]
              ++ lib.optional config.wayland.windowManager.hyprland.enable "hyprtoolkit"
              ++ lib.optional config.programs.wezterm.enable "wezterm"
            );
      };

      wallpaper = {
        enabled = true;
        automationEnabled = false;

        directory =
          let
            cfg = config.setup.desktopEnvironments;
          in
          (pkgs.runCommand "noctalia-wallpapers" { } (
            if builtins.isPath cfg.background then
              ''
                mkdir $out
                cp ${cfg.background} $out/
              ''
            else
              ''
                mkdir $out
                cp ${cfg.background.light} $out/
                cp ${cfg.background.dark} $out/
              ''
          )).outPath;

        fillMode = "crop";
        fillColor = "#000000";

        setWallpaperOnAllMonitors = true;
        enableMultiMonitorDirectories = false;

        panelPosition = "follow_bar";
        hideWallpaperFilenames = true;
        viewMode = "single";
        sortOrder = "name";

        transitionType = "random";
        transitionDuration = 1500;
        transitionEdgeSmoothness = 0.05;
        skipStartupTransition = false;

        overviewEnabled = false;
        useSolidColor = false;
        useWallhaven = false;
      };

      hooks = {
        startup = lib.getExe (
          pkgs.writeShellApplication {
            name = "noctalia-startup-hook";
            runtimeInputs = [
              pkgs.sunwait
              config.programs.noctalia-shell.package
            ];

            bashOptions = [
              # "errexit" # Sunwait exits non-zero
              "nounset"
              "pipefail"
            ];

            text = ''
              # Location is London, same as sunsetr
              r="$(sunwait poll civil 51.508415N 0.125533W 2> /dev/null)"
              if [[ "$r" == "DAY" ]]; then
                noctalia-shell ipc call darkMode setLight
              else
                noctalia-shell ipc call darkMode setDark
              fi
            '';
          }
        );

        darkModeChange =
          let
            cfg = config.setup.desktopEnvironments;

            change =
              let
                is-hyprland = config.wayland.windowManager.hyprland.enable;

                is-zellij = config.programs.zellij.enable;

                zellij-themes = pkgs.runCommand "zellij-noctalia" { } ''
                  mkdir $out
                  sed "s/catppuccin-macchiato/noctalia/" ${pkgs.zellij.src}/zellij-utils/assets/themes/catppuccin-macchiato.kdl > $out/dark.kdl
                  sed "s/catppuccin-latte/noctalia/" ${pkgs.zellij.src}/zellij-utils/assets/themes/catppuccin-latte.kdl > $out/light.kdl
                '';
              in
              lib.getExe (
                pkgs.writeShellApplication {
                  name = "noctalia-dark-mode-hook";
                  runtimeInputs = [
                    pkgs.dconf
                    config.programs.noctalia-shell.package
                  ]
                  ++ lib.optional is-hyprland config.wayland.windowManager.hyprland.package;

                  text = ''
                    dconf write /org/gnome/desktop/interface/gtk-theme '"adw-gtk3"'

                    if [ "$1" = "true" ]; then
                      noctalia-shell ipc call wallpaper set ${cfg.background.dark} ""

                      dconf write /org/gnome/desktop/interface/color-scheme '"prefer-dark"'

                      dconf write /org/gnome/desktop/interface/cursor-theme '"catppuccin-macchiato-light-cursors"'
                      ${if is-hyprland then "hyprctl setcursors catppuccin-macchiato-light-cursors 24" else ""}

                      ${
                        if is-zellij then
                          "install -Dm444 ${zellij-themes}/dark.kdl ${config.xdg.configHome}/zellij/themes/noctalia.kdl"
                        else
                          ""
                      }
                    else
                      noctalia-shell ipc call wallpaper set ${cfg.background.light} ""

                      dconf write /org/gnome/desktop/interface/color-scheme '"prefer-light"'

                      dconf write /org/gnome/desktop/interface/cursor-theme '"catppuccin-latte-dark-cursors"'
                      ${if is-hyprland then "hyprctl setcursors catppuccin-latte-dark-cursors 24" else ""}

                      ${
                        if is-zellij then
                          "install -Dm444 ${zellij-themes}/light.kdl ${config.xdg.configHome}/zellij/themes/noctalia.kdl"
                        else
                          ""
                      }
                    fi
                  '';
                }
              );
          in
          if !(builtins.isPath cfg.background) then ''${change} "$1"'' else "";
      };
    };
  };
}
