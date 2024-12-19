{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup.desktopEnvironments.gnome;
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
          light = "catppuccin-latte-dark-cursors";
          dark = "catppuccin-macchiato-light-cursors";
        };
        gtk =
          if isLaptop
          then {
            light = "catppuccin-latte-mauve-compact+rimless";
            dark = "catppuccin-macchiato-mauve-compact+rimless";
          }
          else {
            light = "catppuccin-latte-mauve-standard+rimless";
            dark = "catppuccin-macchiato-mauve-standard+rimless";
          };
        icons = {
          light = "Papirus-Light";
          dark = "Papirus-Dark";
        };
      };
    }
    .${cfg.theme};

  # Create the gsettings command to switch to the theme of the specified mode
  gsettingsSetCommand = mode:
    lib.concatStringsSep "; "
    [
      ''gsettings set org.gnome.desktop.interface           cursor-theme "${theme.cursors.${mode}}"''
      ''gsettings set org.gnome.desktop.interface           icon-theme   "${theme.icons.${mode}}"''
      ''gsettings set org.gnome.desktop.interface           gtk-theme    "${theme.gtk.${mode}}"''
      ''gsettings set org.gnome.shell.extensions.user-theme name         "${theme.gtk.${mode}}"''
    ];
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.gnome.enable {
    home.packages = theme.pkgs;

    dconf.settings =
      if cfg.enableExtensions
      then {
        "org/gnome/shell/extensions/nightthemeswitcher/commands" = {
          enabled = true;
          sunrise = gsettingsSetCommand "light";
          sunset = gsettingsSetCommand "dark";
        };
      }
      else {
        "org/gnome/shell/extensions/user-theme" = {
          name = theme.gtk.dark;
        };
      };
  };
}
