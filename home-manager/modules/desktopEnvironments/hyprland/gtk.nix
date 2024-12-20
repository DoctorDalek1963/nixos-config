{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    # TODO: Have a setup.desktopEnvironments.hyprland.theme setting?
    home.pointerCursor = {
      gtk.enable = true;
      package = pkgs.catppuccin-cursors.macchiatoLight;
      name = "catppuccin-macchiato-light-cursors";
      size = 24;
    };

    gtk = {
      enable = true;

      theme = {
        package = pkgs.catppuccin-gtk.override {
          accents = ["mauve"];
          size =
            if config.setup.isLaptop
            then "compact"
            else "standard";
          tweaks = ["rimless"];
          variant = "macchiato"; # Dark mode
        };
        name =
          if config.setup.isLaptop
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
