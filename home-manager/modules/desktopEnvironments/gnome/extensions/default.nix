{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  extraExtensions = [
    (pkgs.callPackage ./thanatophobia.nix { })
  ];

  optionalExtensions =
    lib.optionals config.setup.misc.programs.xremap [
      {
        uuid = "activate-window-by-title@lucaswerkmeister.de";
        pkg = pkgs.gnomeExtensions.activate-window-by-title;
      }
      {
        uuid = "xremap@k0kubun.com";
        pkg = pkgs.gnomeExtensions.xremap;
      }
    ]
    ++ lib.optional config.services.easyeffects.enable {
      uuid = "eepresetselector@ulville.github.io";
      pkg = pkgs.gnomeExtensions.easyeffects-preset-selector;
    };
in
{
  config =
    lib.mkIf
      (
        osConfig.setup.desktopEnvironments.gnome.enable
        && config.setup.desktopEnvironments.gnome.enableExtensions
      )
      {
        home.packages =
          (with pkgs.gnomeExtensions; [
            appindicator
            caffeine
            clipboard-indicator
            dash-to-dock
            gnome-bedtime
            lock-keys
            night-theme-switcher
            panel-date-format
          ])
          ++ extraExtensions
          ++ (map (
            {
              # deadnix: skip
              uuid,
              pkg,
            }:
            pkg
          ) optionalExtensions);

        dconf.settings = {
          "org/gnome/shell" = {
            disable-user-extensions = false;
            disabled-extensions = [
              "apps-menu@gnome-shell-extensions.gcampax.github.com"
              "auto-move-windows@gnome-shell-extensions.gcampax.github.com"
              "light-style@gnome-shell-extensions.gcampax.github.com"
              "native-window-placement@gnome-shell-extensions.gcampax.github.com"
              "places-menu@gnome-shell-extensions.gcampax.github.com"
              "window-list@gnome-shell-extensions.gcampax.github.com"
              "workspace-indicator@gnome-shell-extensions.gcampax.github.com"
            ];
            enabled-extensions = [
              # Built-in to GNOME 45+
              "drive-menu@gnome-shell-extensions.gcampax.github.com"
              "user-theme@gnome-shell-extensions.gcampax.github.com"

              "appindicatorsupport@rgcjonas.gmail.com"
              "caffeine@patapon.info"
              "clipboard-indicator@tudmotu.com"
              "dash-to-dock@micxgx.gmail.com"
              "gnomebedtime@ionutbortis.gmail.com"
              "lockkeys@vaina.lt"
              "nightthemeswitcher@romainvigier.fr"
              "panel-date-format@keiii.github.com"
              "thanatophobia@yatx.one"
            ]
            ++ (map (
              {
                uuid,
                # deadnix: skip
                pkg,
              }:
              uuid
            ) optionalExtensions);
          };

          "org/gnome/shell/extensions/bedtime-mode" = {
            automatic-schedule = true;
            schedule-start-hours = 22;
            schedule-start-minutes = 30;
            schedule-end-hours = 7;
            schedule-end-minutes = 0;

            ondemand-button-visibility = "never";
            color-tone-preset = "grayscale";
            color-tone-factor = 80;
          };

          "org/gnome/shell/extensions/caffeine" = {
            countdown-timer = 0;
            enable-fullscreen = false;
            inhibit-apps = [ ];
            show-indicator = "only-active";
            toggle-state = false;
            trigger-apps-mode = "on-focus";
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
            nightthemeswitcher-ondemand-keybinding = [ "<Shift><Super>t" ];
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
