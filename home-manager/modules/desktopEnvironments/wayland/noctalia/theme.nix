{
  pkgs,
  lib,
  config,
  ...
}:
let
  ipc = "${lib.getExe config.programs.noctalia-shell.package} ipc";
in
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
        predefinedScheme = "Catppuccin"; # TODO: Create custom
      };

      templates = {
        enableUserTheming = false;

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
                # "wezterm"
                # "yazi"
                # "zathura"
              ]
              ++ lib.optional config.wayland.windowManager.hyprland.enable "hyprtoolkit"
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

      hooks.darkModeChange =
        let
          cfg = config.setup.desktopEnvironments;

          change = lib.getExe (
            pkgs.writeShellApplication {
              name = "noctalia-dark-mode-hook";
              runtimeInputs = [
                pkgs.dconf
              ]
              ++ lib.optional config.wayland.windowManager.hyprland.enable config.wayland.windowManager.hyprland.package;

              text = ''
                dconf write /org/gnome/desktop/interface/gtk-theme '"adw-gtk3"'

                if [ "$1" = "true" ]; then
                  ${ipc} call wallpaper set ${cfg.background.dark} ""

                  dconf write /org/gnome/desktop/interface/color-scheme '"prefer-dark"'

                  dconf write /org/gnome/desktop/interface/cursor-theme '"catppuccin-macchiato-light-cursors"'
                  ${
                    if config.wayland.windowManager.hyprland.enable then
                      "hyprctl setcursors catppuccin-macchiato-light-cursors 24"
                    else
                      ""
                  }
                else
                  ${ipc} call wallpaper set ${cfg.background.light} ""

                  dconf write /org/gnome/desktop/interface/color-scheme '"prefer-light"'

                  dconf write /org/gnome/desktop/interface/cursor-theme '"catppuccin-latte-dark-cursors"'
                  ${
                    if config.wayland.windowManager.hyprland.enable then
                      "hyprctl setcursors catppuccin-latte-dark-cursors 24"
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
}
