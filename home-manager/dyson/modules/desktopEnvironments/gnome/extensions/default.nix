{
  pkgs,
  lib,
  config,
  ...
}: let
  extraExtensions = [
    (pkgs.callPackage ./thanatophobia.nix {})
  ];

  optionalExtensions =
    (
      if config.setup.rclone.enable
      then [(pkgs.callPackage ./rclone-manager.nix {})]
      else []
    )
    ++ (
      if config.setup.miscPrograms.xremap
      then with pkgs.gnomeExtensions; [activate-window-by-title xremap]
      else []
    );

  optionalExtensionsNames =
    (
      if config.setup.rclone.enable
      then ["rclone-manager@germanztz.com"]
      else []
    )
    ++ (
      if config.setup.miscPrograms.xremap
      then ["activate-window-by-title@lucaswerkmeister.de" "xremap@k0kubun.com"]
      else []
    );

  gnomeCfg = config.setup.desktopEnvironments.gnome;
in {
  config = lib.mkIf (gnomeCfg.enable && gnomeCfg.enableExtensions) {
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
      ++ extraExtensions
      ++ optionalExtensions;

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
        enabled-extensions =
          [
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
          ]
          ++ optionalExtensionsNames;
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

      # The theme settings for Night Theme Switcher are in ../themes.nix
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
    };
  };
}
