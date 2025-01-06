{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  theme-config =
    {
      "catppuccin-macchiato-mauve" = {
        home.pointerCursor = {
          package = pkgs.catppuccin-cursors.macchiatoLight;
          name = "catppuccin-macchiato-light-cursors";
        };

        gtk = {
          theme = {
            package = pkgs.catppuccin-gtk.override {
              accents = ["mauve"];
              size =
                if osConfig.setup.isLaptop
                then "compact"
                else "standard";
              tweaks = ["rimless"];
              variant = "macchiato"; # Dark mode
            };
            name =
              if osConfig.setup.isLaptop
              then "catppuccin-macchiato-mauve-compact+rimless"
              else "catppuccin-macchiato-mauve-standard+rimless";
          };

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
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home.pointerCursor = {
      gtk.enable = true;
      size = 24;

      inherit (theme-config.home.pointerCursor) package name;
    };

    gtk = {
      enable = true;

      inherit (theme-config.gtk) theme iconTheme;
    };
  };
}
