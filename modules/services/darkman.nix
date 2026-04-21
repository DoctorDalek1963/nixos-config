{
  flake.aspects.darkman.homeManager =
    {
      pkgs,
      lib,
      config,
      ...
    }:
    {
      xdg.configFile."xdg-desktop-portal/portals.conf".text = ''
        [preferred]
        org.freedesktop.impl.portal.Settings=darkman
      '';

      services.darkman = {
        enable = true;

        settings = {
          # London, like sunsetr
          lat = 51.51;
          lng = -0.13;
          usegeoclue = false;
          dbusserver = true;
          portal = true;
        };

        # Darkman calls Noctalia to set the mode and Noctalia calls darkman
        # after the mode is set. This doesn't cause problems when manually
        # changing the mode in Noctalia because it will only call the hook if
        # the mode has actually changed

        # TODO: Should I separate these to their own aspects?
        scripts = {
          noctalia = lib.mkIf config.programs.noctalia-shell.enable (
            let
              script = lib.getExe (
                pkgs.writeShellApplication {
                  name = "noctalia-theme-switch";
                  runtimeInputs = [
                    pkgs.gawk
                    config.programs.noctalia-shell.package
                  ];

                  text = ''
                    pid="$(noctalia-shell list --all | awk -F": " '$1 ~ /\s*Process ID/ {print $2}')"

                    case "$1" in
                      light) noctalia-shell ipc --pid "$pid" call darkMode setLight ;;
                      dark) noctalia-shell ipc --pid "$pid" call darkMode setDark ;;
                    esac
                  '';
                }
              );
            in
            ''${script} "$1"''
          );

          gtk-theme = ''
            ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/gtk-theme '"adw-gtk3"'

            case "$1" in
              light) ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme '"prefer-light"' ;;
              dark) ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/color-scheme '"prefer-dark"' ;;
            esac
          '';

          xcursor = ''
            case "$1" in
              light) ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/cursor-theme '"catppuccin-latte-dark-cursors"' ;;
              dark) ${lib.getExe pkgs.dconf} write /org/gnome/desktop/interface/cursor-theme '"catppuccin-macchiato-light-cursors"' ;;
            esac
          '';

          bat = lib.mkIf config.programs.bat.enable ''
            cd ${config.xdg.configHome}/bat/themes

            case "$1" in
              light) ${lib.getExe' pkgs.coreutils "ln"} -sf catppuccin-latte.tmTheme noctalia.tmTheme ;;
              dark) ${lib.getExe' pkgs.coreutils "ln"} -sf catppuccin-macchiato.tmTheme noctalia.tmTheme ;;
            esac

            ${lib.getExe config.programs.bat.package} cache --build
          '';

          zellij = lib.mkIf config.programs.zellij.enable (
            let
              zellij-themes = pkgs.runCommand "zellij-noctalia" { } ''
                mkdir $out
                sed "s/catppuccin-macchiato/noctalia/" ${pkgs.zellij.src}/zellij-utils/assets/themes/catppuccin-macchiato.kdl > $out/dark.kdl
                sed "s/catppuccin-latte/noctalia/" ${pkgs.zellij.src}/zellij-utils/assets/themes/catppuccin-latte.kdl > $out/light.kdl
              '';
            in
            ''
              case "$1" in
                light) ${lib.getExe' pkgs.coreutils "install"} -Dm444 ${zellij-themes}/light.kdl ${config.xdg.configHome}/zellij/themes/noctalia.kdl ;;
                dark) ${lib.getExe' pkgs.coreutils "install"} -Dm444 ${zellij-themes}/dark.kdl ${config.xdg.configHome}/zellij/themes/noctalia.kdl ;;
              esac
            ''
          );
        };
      };
    };
}
