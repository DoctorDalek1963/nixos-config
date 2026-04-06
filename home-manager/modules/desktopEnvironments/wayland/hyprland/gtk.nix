{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  theme-config =
    {
      "catppuccin-macchiato-mauve" = {
        cursor = {
          package = pkgs.catppuccin-cursors.macchiatoLight;
          name = "catppuccin-macchiato-light-cursors";
          extras = [
            {
              package = pkgs.catppuccin-cursors.latteDark;
              name = "catppuccin-latte-dark-cursors";
            }
          ];
        };

        gtk = {
          iconTheme = {
            package = pkgs.catppuccin-papirus-folders.override {
              accent = "mauve";
              flavor = "macchiato"; # Dark mode
            };
            name = "Papirus-Dark";
          };
        };
      };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};
in
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    xdg.dataFile = lib.foldl (acc: attrs: acc // attrs) { } (
      map (
        { package, name }:
        {
          "icons/${name}".source = "${package}/share/icons/${name}";
        }
      ) theme-config.cursor.extras
    );

    home = {
      pointerCursor = {
        gtk.enable = true;
        size = 24;

        inherit (theme-config.cursor) name package;
      };
    };

    gtk = {
      enable = true;
      inherit (theme-config.gtk) iconTheme;

      gtk4.theme = config.gtk.theme;
    };
  };
}
