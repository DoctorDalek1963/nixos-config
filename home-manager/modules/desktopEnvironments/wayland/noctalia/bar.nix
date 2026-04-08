{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
{
  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    programs.noctalia-shell = {
      settings.bar = {
        barType = "simple";
        position = "top";
        density = "comfortable";

        showCapsule = true;
        capsuleOpacity = 1;

        floating = false;
        outerCorners = false;
        displayMode = "always_visible";

        useSeparateOpacity = true;
        backgroundOpacity = 1;
        frameRadius = 12;
        frameThickness = 8;
        marginHorizontal = 5;
        marginVertical = 5;

        widgets = {
          left = [
            {
              id = "ControlCenter";

              useDistroLogo = true;
              enableColorization = true;
              colorizeSystemIcon = "tertiary";
            }
            {
              id = "Workspace";

              showApplications = true;
              showBadge = true;
              colorizeIcons = false;
              unfocusedIconsOpacity = 0.5;

              groupedBorderOpacity = 1;
              pillSize = 1;
              iconScale = 0.8;
              labelMode = "index";

              enableScrollWheel = true;
              reverseScroll = false;

              focusedColor = "primary";
              followFocusedScreen = false;

              occupiedColor = "secondary";

              emptyColor = "tertiary";
              hideUnoccupied = true;
            }
            {
              id = "SystemMonitor";

              compactMode = false;
              iconColor = "primary";
              textColor = "none";
              useMonospaceFont = true;

              showCpuUsage = true;
              showCpuTemp = true;
              showCpuFreq = false;
              showMemoryUsage = true;
              showMemoryAsPercent = true;

              showDiskUsage = false;
              showGpuTemp = false;
              showLoadAverage = false;
              showNetworkStats = false;
              showSwapUsage = false;
            }
            {
              id = "ActiveWindow";

              showIcon = true;
              colorizeIcons = false;
              textColor = "none";

              hideMode = "hidden";
              useFixedWidth = false;
              maxWidth = 200;
              scrollingMode = "hover";
            }
          ];

          center = [
            {
              id = "Clock";

              clockColor = "primary";
              formatHorizontal = "h:mm:ss ap, dddd dd MMMM 12,0yy";
              formatVertical = "";
              tooltipFormat = "";
              useCustomFont = false;
            }
            {
              id = "MediaMini";

              compactMode = true;
              compactShowAlbumArt = true;
              compactShowVisualizer = false;

              hideMode = "idle";
              useFixedWidth = false;
              maxWidth = 200;
              scrollingMode = "hover";

              panelShowAlbumArt = true;
              panelShowVisualizer = true;
              showAlbumArt = true;
              showArtistFirst = false;
              showProgressRing = true;
              showVisualizer = false;
              textColor = "secondary";
            }
          ];

          right = [
            {
              id = "Tray";

              drawerEnabled = false;
              colorizeIcons = false;
              hidePassive = false;
            }
            {
              id = "NotificationHistory";

              iconColor = "secondary";
              unreadBadgeColor = "primary";

              hideWhenZero = false;
              hideWhenZeroUnread = false;
              showUnreadBadge = true;
            }
            {
              id = "DarkMode";

              iconColor = "tertiary";
            }
          ]
          ++ lib.optional config.services.hypridle.enable {
            id = "KeepAwake";

            iconColor = "secondary";
            textColor = "none";
          }
          ++ lib.optionals osConfig.setup.isLaptop [
            {
              id = "PowerProfile";

              iconColor = "none";
            }
            {
              id = "Battery";

              deviceNativePath = "__default__";
              displayMode = "graphic";
              hideIfIdle = false;
              hideIfNotDetected = false;
              showPowerProfiles = false;
              showNoctaliaPerformance = true;
            }
          ]
          ++ [
            {
              id = "Volume";

              displayMode = "alwaysShow";
              iconColor = "secondary";
              textColor = "none";
              middleClickCommand = "${lib.getExe pkgs.pwvucontrol}";
            }
          ]
          ++ lib.optional osConfig.setup.isLaptop {
            id = "Bluetooth";

            iconColor = "tertiary";
            displayMode = "alwaysHide";
          }
          ++ [
            {
              id = "Network";

              displayMode = "alwaysShow";
              iconColor = "tertiary";
              textColor = "none";
            }
            {
              id = "SessionMenu";

              iconColor = "error";
            }
          ];
        };
      };

      plugins = {
        sources = [
          {
            enabled = true;
            name = "Official Noctalia Plugins";
            url = "https://github.com/noctalia-dev/noctalia-plugins";
          }
        ];
        states = {
          current-age = {
            enabled = true;
            sourceUrl = "https://github.com/noctalia-dev/noctalia-plugins";
          };
        };
        version = 2;
      };

      pluginSettings = {
        current-age = {
          dateOfBirth = "2005-03-19T03:01:00";
        };
      };
    };

    # xdg.configFile."noctalia/plugins/current-age".source = ./current-age;
    # home.file.".config/noctalia/plugins/current-age".source = ./current-age;
  };
}
