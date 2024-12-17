{
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup.desktopEnvironments.cinnamon;

  cursor-theme = cfg.theme.cursor;
  gtk-theme = cfg.theme.gtk;
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.cinnamon.enable {
    dconf.settings = {
      "org/cinnamon/desktop/interface" = {
        inherit gtk-theme cursor-theme;
        icon-theme = gtk-theme;
      };

      "org/gnome/desktop/interface" = {
        inherit gtk-theme cursor-theme;
        icon-theme = gtk-theme;
      };

      "org/cinnamon/theme" = {
        name = gtk-theme;
      };

      "org/x/apps/portal" = {
        color-scheme =
          if lib.hasInfix "dark" gtk-theme
          then "prefer-dark"
          else "prefer-light";
      };
    };
  };
}
