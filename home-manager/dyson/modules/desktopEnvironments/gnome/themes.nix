{
  pkgs,
  lib,
  config,
  ...
}: let
  gnomeCfg = config.setup.desktopEnvironments.gnome;
  inherit (config.setup) isLaptop;

  theme =
    if gnomeCfg.theme == "vimix-amethyst"
    then {
      pkgs = with pkgs; [
        vimix-cursors
        (vimix-gtk-themes.override
          {
            colorVariants = ["standard" "light" "dark"];
            sizeVariants = [
              (
                if isLaptop
                then "compact"
                else "standard"
              )
            ];
            themeVariants = ["amethyst"];
          })
        (vimix-icon-theme.override
          {
            colorVariants = ["Amethyst"];
          })
      ];
      cursors = {
        light = "Vimix-cursors";
        dark = "Vimix-white-cursors";
      };
      gtk =
        if isLaptop
        then {
          light = "vimix-compact-amethyst";
          dark = "vimix-dark-compact-amethyst";
        }
        else {
          light = "vimix-amethyst";
          dark = "vimix-dark-amethyst";
        };
      icons = {
        light = "Vimix-Amethyst";
        dark = "Vimix-Amethyst-dark";
      };
      user-theme =
        if isLaptop
        then "vimix-dark-compact-amethyst"
        else "vimix-dark-amethyst";
    }
    else abort "Unsupported GNOME theme: ${gnomeCfg.theme}";
in {
  config = lib.mkIf gnomeCfg.enable {
    home.packages = theme.pkgs;

    dconf.settings =
      {
        "org/gnome/shell/extensions/user-theme" = {
          name = theme.user-theme;
        };
      }
      // (
        if gnomeCfg.enableExtensions
        then {
          "org/gnome/shell/extensions/nightthemeswitcher/cursor-variants" = {
            day = theme.cursors.light;
            enabled = true;
            night = theme.cursors.dark;
          };

          # This should only affect legacy GTK apps. If it starts to break things, just disable it
          "org/gnome/shell/extensions/nightthemeswitcher/gtk-variants" = {
            day = theme.gtk.light;
            enabled = true;
            night = theme.gtk.dark;
          };

          "org/gnome/shell/extensions/nightthemeswitcher/icon-variants" = {
            day = theme.icons.light;
            enabled = true;
            night = theme.icons.dark;
          };

          "org/gnome/shell/extensions/nightthemeswitcher/shell-variants" = {
            enabled = false;
          };
        }
        else {}
      );
  };
}
