{pkgs, ...}: let
  thanatophobia = pkgs.callPackage ./thanatophobia.nix {};
in {
  home.packages =
    (with pkgs.gnomeExtensions; [
      appindicator
      caffeine
      clipboard-indicator
      dash-to-dock
      lock-keys
      night-theme-switcher
      panel-date-format
    ])
    ++ [thanatophobia]
    ++ (with pkgs; [
      vimix-cursors
      (vimix-gtk-themes.override
        {
          colorVariants = ["standard" "light" "dark"];
          sizeVariants = ["standard"]; # TODO: Switch to "compact" for laptops
          themeVariants = ["amethyst"];
        })
      (vimix-icon-theme.override
        {
          colorVariants = ["Amethyst"];
        })
    ]);

  dconf.settings = {
    "org/gnome/shell" = {
      disable-user-extensions = false;
      disabled-extensions = [
        "apps-menu@gnome-shell-extensions.gcampax.github.com"
        "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
        "light-style@gnome-shell-extensions.gcampax.github.com"
        "native-window-placement@gnome-shell-extensions.gcampax.github.com"
        "window-list@gnome-shell-extensions.gcampax.github.com"
      ];
      enabled-extensions = [
        # Built-in to GNOME 45
        "places-menu@gnome-shell-extensions.gcampax.github.com"
        "drive-menu@gnome-shell-extensions.gcampax.github.com"
        "user-theme@gnome-shell-extensions.gcampax.github.com"
        "workspace-indicator@gnome-shell-extensions.gcampax.github.com"

        "appindicatorsupport@rgcjonas.gmail.com"
        "caffeine@patapon.info"
        "clipboard-indicator@tudmotu.com"
        "dash-to-dock@micxgx.gmail.com"
        "lockkeys@vaina.lt"
        "nightthemeswitcher@romainvigier.fr"
        "panel-date-format@keiii.github.com"
        "thanatophobia@yatx.one"
      ];
    };

    "org/gnome/shell/extensions/caffeine" = {
      countdown-timer = 0;
      show-indicator = "only-active";
      toggle-state = false;
    };

    "org/gnome/shell/extensions/clipboard-indicator" = {
      cache-only-favorites = true;
      enable-keybindings = false;
    };

    "org/gnome/shell/extensions/dash-to-dock" = {
      apply-custom-theme = false;
      autohide = false;
      background-opacity = 0.0;
      custom-theme-shrink = false;
      dash-max-icon-size = 24;
      disable-overview-on-startup = true;
      dock-fixed = false;
      dock-position = "LEFT";
      extend-height = true;
      height-fraction = 0.9;
      intellihide = false;
      intellihide-mode = "FOCUS_APPLICATION_WINDOWS";
      show-icons-emblems = false;
      show-trash = false;
      transparency-mode = "FIXED";
    };

    "org/gnome/shell/extensions/lockkeys" = {
      style = "capslock";
    };

    "org/gnome/shell/extensions/nightthemeswitcher/cursor-variants" = {
      day = "Vimix-cursors";
      enabled = true;
      night = "Vimix-white-cursors";
    };

    # This should only affect legacy GTK apps. If it starts to break things, just disable it
    "org/gnome/shell/extensions/nightthemeswitcher/gtk-variants" = {
      day = "vimix-amethyst";
      enabled = true;
      night = "vimix-dark-amethyst";
    };

    "org/gnome/shell/extensions/nightthemeswitcher/icon-variants" = {
      day = "Vimix-Amethyst";
      enabled = true;
      night = "Vimix-Amethyst-dark";
    };

    "org/gnome/shell/extensions/nightthemeswitcher/shell-variants" = {
      enabled = false;
    };

    "org/gnome/shell/extensions/nightthemeswitcher/time" = {
      manual-schedule = true;
      nightthemeswitcher-ondemand-keybinding = ["<Shift><Super>t"];
      schedule-sunset = 18.25;
      schedule-sunrise = 6.5;
    };

    "org/gnome/shell/extensions/panel-date-format" = {
      format = "%l:%M:%S %p, %A %e %B 12,0%y";
    };

    "org/gnome/shell/extensions/thanatophobia" = {
      countdown = 0;
      country = "GBR";
      day = 19;
      hour = 3;
      minute = 1;
      month = 3;
      rounding = 7;
      sex = 1;
      year = 2005;
    };

    "org/gnome/shell/extensions/user-theme" = {
      name = "vimix-dark-amethyst";
    };
  };
}
