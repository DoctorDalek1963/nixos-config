{
  pkgs,
  lib,
  config,
  ...
}: let
  gnomeCfg = config.setup.desktopEnvironments.gnome;
  inherit (config.setup) isLaptop;

  theme =
    {
      vimix-amethyst = {
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
      };
      catppuccin-adaptive-macchiato-mauve = {
        pkgs = with pkgs; [
          catppuccin-cursors.latteDark # Light mode
          catppuccin-cursors.macchiatoLight # Dark mode
          (catppuccin-gtk.override {
            accents = ["mauve"];
            size =
              if isLaptop
              then "compact"
              else "standard";
            tweaks = ["rimless"];
            variant = "latte"; # Light mode
          })
          (catppuccin-gtk.override {
            accents = ["mauve"];
            size =
              if isLaptop
              then "compact"
              else "standard";
            tweaks = ["rimless"];
            variant = "macchiato"; # Dark mode
          })
          # We can't currently install catppuccin-papirus-folders with multiple
          # flavors because they collide. I don't know why this happens or how
          # else to fix it
          # (catppuccin-papirus-folders.override {
          #   accent = "mauve";
          #   flavor = "latte"; # Light mode
          # })
          (catppuccin-papirus-folders.override {
            accent = "mauve";
            flavor = "macchiato"; # Dark mode
          })
        ];
        cursors = {
          light = "Catppuccin-Latte-Dark-Cursors";
          dark = "Catppuccin-Macchiato-Light-Cursors";
        };
        gtk =
          if isLaptop
          then {
            light = "Catppuccin-Latte-Compact-Mauve-Light";
            dark = "Catppuccin-Macchiato-Compact-Mauve-Dark";
          }
          else {
            light = "Catppuccin-Latte-Standard-Mauve-Light";
            dark = "Catppuccin-Macchiato-Standard-Mauve-Dark";
          };
        icons = {
          light = "Papirus-Light";
          dark = "Papirus-Dark";
        };
      };
    }
    .${gnomeCfg.theme};
in {
  config = lib.mkIf gnomeCfg.enable {
    home.packages = theme.pkgs;

    dconf.settings =
      {
        "org/gnome/shell/extensions/user-theme" = {
          name = theme.gtk.dark;
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
