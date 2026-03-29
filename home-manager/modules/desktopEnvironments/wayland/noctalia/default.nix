{
  pkgs,
  lib,
  config,
  osConfig,
  inputs,
  ...
}:
let
  ipc = "${lib.getExe config.programs.noctalia-shell.package} ipc";

  useUwsm = config.wayland.windowManager.hyprland.enable && osConfig.programs.hyprland.withUWSM;
in
{
  imports = [ inputs.noctalia.homeModules.default ];

  config = lib.mkIf config.wayland.windowManager.hyprland.enable {
    programs.noctalia-shell = {
      enable = true;

      package = pkgs.noctalia-shell.override {
        bluetoothSupport = osConfig.setup.isLaptop;
        brightnessctlSupport = true;
        cavaSupport = false;
        cliphistSupport = true;
        ddcutilSupport = true;
        wlsunsetSupport = false;
        wl-clipboardSupport = true;
        # wlr-randrSupport = true;
        imagemagickSupport = true;
        calendarSupport = false;
      };

      settings = {
        # TODO: Create custom plugin for current_age.py

        desktopWidgets.enabled = false;
        dock.enabled = false;
        nightLight.enabled = false;

        general = {
          telemetryEnabled = false;
          language = "en";
          avatarImage = osConfig.setup.profilePictures.${config.setup.username};
          keybinds = {
            keyDown = [ "Down" ];
            keyEnter = [ "Return" ];
            keyEscape = [ "Esc" ];
            keyLeft = [ "Left" ];
            keyRight = [ "Right" ];
            keyUp = [ "Up" ];
          };

          # Lock screen
          compactLockScreen = true;
          clockStyle = "custom";
          clockFormat = "h:mm ap";
          enableLockScreenCountdown = true;
          lockScreenCountdownDuration = 10000;
          lockOnSuspend = true;
          lockScreenAnimations = true;
          lockScreenMonitors = [ ];
          lockScreenBlur = 0.5;
          lockScreenTint = 0;
          showSessionButtonsOnLockScreen = false;
          showHibernateOnLockScreen = false;
          allowPasswordWithFprintd = true;
          autoStartAuth = false;

          showChangelogOnStartup = false;
          allowPanelsOnScreenWithoutBar = true;
          dimmerOpacity = 0.2;

          animationDisabled = false;
          animationSpeed = 1.4;

          boxRadiusRatio = 1;
          iRadiusRatio = 1;
          radiusRatio = 1;
          scaleRatio = 1;
          screenRadiusRatio = 1;

          showScreenCorners = false;
          forceBlackScreenCorners = false;

          enableShadows = false;
          shadowDirection = "bottom_left";
          shadowOffsetX = -2;
          shadowOffsetY = 2;
        };

        controlCenter = {
          diskPath = "/";
          position = "close_to_bar_button";

          cards = [
            {
              enabled = true;
              id = "profile-card";
            }
            {
              enabled = false;
              id = "shortcuts-card";
            }
            {
              enabled = true;
              id = "audio-card";
            }
            {
              enabled = true;
              id = "brightness-card";
            }
            {
              enabled = false;
              id = "weather-card";
            }
            {
              enabled = true;
              id = "media-sysmon-card";
            }
          ];
        };

        hooks = {
          enabled = true;

          screenLock = "${ipc} media pause";

          darkModeChange =
            let
              cfg = config.setup.desktopEnvironments;

              change = pkgs.writeShellScript "change-noctalia-wallpaper-dark-mode" ''
                if [ "$1" = "true" ]; then
                  ${ipc} call wallpaper set ${cfg.background.dark} ""
                else
                  ${ipc} call wallpaper set ${cfg.background.light} ""
                fi
              '';
            in
            if !(builtins.isPath cfg.background) then ''${change} "$1"'' else "";
        };

        appLauncher =
          let
            wl-paste = "${pkgs.wl-clipboard}/bin/wl-paste";
          in
          {
            customLaunchPrefixEnabled = useUwsm;
            customLaunchPrefix = "${osConfig.programs.uwsm.package}/bin/uwsm app --";

            terminalCommand =
              {
                wezterm = "${lib.getExe config.programs.wezterm.package} start --always-new-process";
              }
              .${config.setup.terminal.emulator} or (abort "Unsupported terminal emulator");

            enableClipPreview = true;
            enableClipboardHistory = true;
            autoPasteClipboard = false;
            clipboardWrapText = true;
            clipboardWatchImageCommand = "${wl-paste} --type image --watch cliphist store";
            clipboardWatchTextCommand = "${wl-paste} --type text --watch cliphist store";

            enableSessionSearch = true;
            enableSettingsSearch = true;
            enableWindowsSearch = true;
            showCategories = true;
            showIconBackground = false;

            density = "default";
            iconMode = "tabler";
            viewMode = "list";
            position = "center";
            ignoreMouseInput = false;
            overviewLayer = true;
            sortByMostUsed = true;
            useApp2Unit = false;
            screenshotAnnotationTool = "";
            pinnedApps = [ ];
          };

        audio = {
          volumeStep = 5;
          volumeOverdrive = true;
          volumeFeedback = false;
        };

        brightness = {
          brightnessStep = 5;
          enforceMinimum = true;
          enableDdcSupport = true;
        };

        network = {
          wifiEnabled = true;
          wifiDetailsViewMode = "grid";

          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;
          bluetoothRssiPollingEnabled = false;
          bluetoothRssiPollIntervalMs = 10000;
        };

        notifications = {
          enabled = true;
          location = "top_right";

          normalUrgencyDuration = 8;
          lowUrgencyDuration = 8;
          criticalUrgencyDuration = 15;
          respectExpireTimeout = false;

          overlayLayer = true;
          backgroundOpacity = 0.75;

          enableBatteryToast = true;
          enableKeyboardLayoutToast = true;
          enableMediaToast = false;

          saveToHistory = {
            low = false;
            normal = true;
            critical = true;
          };

          sounds.enabled = false;
        };

        osd = {
          enabled = true;

          location = "bottom_center";
          autoHideMs = 2000;
          overlayLayer = true;
          backgroundOpacity = 0.75;

          enabledTypes = [
            0 # Output volume
            1 # Input volume
            2 # Brightness
          ];
        };

        systemMonitor = {
          externalMonitor =
            if config.setup.terminal.tools.btop.enable then
              let
                terminal =
                  {
                    wezterm = ''${lib.getExe config.programs.wezterm.package} --config 'window_close_confirmation="NeverPrompt"' start --always-new-process'';
                  }
                  .${config.setup.terminal.emulator} or (abort "Unsupported terminal emulator");
              in
              "${terminal} ${lib.getExe config.programs.btop.package}"
            else
              "";

          useCustomColors = false;

          batteryWarningThreshold = 20;
          batteryCriticalThreshold = 10;

          cpuWarningThreshold = 80;
          cpuCriticalThreshold = 90;

          diskWarningThreshold = 80;
          diskCriticalThreshold = 90;
          diskAvailWarningThreshold = 20;
          diskAvailCriticalThreshold = 10;

          enableDgpuMonitoring = !osConfig.setup.isLaptop;
          gpuWarningThreshold = 80;
          gpuCriticalThreshold = 90;

          memWarningThreshold = 80;
          memCriticalThreshold = 90;

          swapWarningThreshold = 80;
          swapCriticalThreshold = 90;

          tempWarningThreshold = 80;
          tempCriticalThreshold = 90;
        };

        calendar = {
          cards = [
            {
              enabled = true;
              id = "calendar-header-card";
            }
            {
              enabled = true;
              id = "calendar-month-card";
            }
            {
              enabled = false;
              id = "weather-card";
            }
          ];
        };

        location = {
          name = "London, UK";

          use12hourFormat = true;
          firstDayOfWeek = 1;
          useFahrenheit = false;

          weatherEnabled = false;

          analogClockInCalendar = false;
          showCalendarEvents = true;
          showWeekNumberInCalendar = false;
        };

        sessionMenu = {
          enableCountdown = true;
          countdownDuration = 5000;

          largeButtonsStyle = false;
          position = "center";
          showHeader = true;

          powerOptions =
            map
              (
                x:
                {
                  enabled = true;
                  countdownEnabled = true;
                  command = "";
                }
                // x
              )
              [
                {
                  action = "lock";
                  keybind = "1";
                }
                {
                  action = "suspend";
                  keybind = "2";
                }
                {
                  action = "hibernate";
                  keybind = "3";
                }
                {
                  action = "reboot";
                  keybind = "4";
                }
                {
                  action = "logout";
                  keybind = "5";

                  command =
                    if useUwsm then
                      "${lib.getExe osConfig.programs.uwsm.package} stop"
                    else if config.wayland.windowManager.hyprland.enable then
                      "${config.wayland.windowManager.hyprland.package}/bin/hyprctl dispatch exit"
                    else
                      "";
                }
                {
                  action = "shutdown";
                  keybind = "6";
                }
                {
                  action = "rebootToUefi";
                  keybind = "7";
                }
              ];
        };

        colorSchemes = {
          useWallpaperColors = false;
          generationMethod = "tonal-spot";

          schedulingMode = "location";
          predefinedScheme = "Catppuccin Lavender"; # TODO: Create custom
        };

        templates = {
          enableUserTheming = false;
          activeTemplates = [ ];
        };

        ui = {
          fontDefault = "Sans Serif";
          fontDefaultScale = 1;
          fontFixed = "monospace";
          fontFixedScale = 1;

          networkPanelView = "wifi";
          wifiDetailsViewMode = "grid";
          bluetoothDetailsViewMode = "grid";
          bluetoothHideUnnamedDevices = false;

          panelsAttachedToBar = true;
          panelBackgroundOpacity = 0.5;
          settingsPanelMode = "attached";
          boxBorderEnabled = true;
          tooltipsEnabled = true;
        };

        wallpaper = {
          enabled = true;
          automationEnabled = false;

          directory =
            let
              cfg = config.setup.desktopEnvironments;
            in
            (pkgs.runCommand "noctalia-wallpapers" { } (
              if builtins.isPath cfg.background then
                ''
                  mkdir $out
                  cp ${cfg.background} $out/
                ''
              else
                ''
                  mkdir $out
                  cp ${cfg.background.light} $out/
                  cp ${cfg.background.dark} $out/
                ''
            )).outPath;

          fillMode = "crop";
          fillColor = "#000000";

          setWallpaperOnAllMonitors = true;
          enableMultiMonitorDirectories = false;

          panelPosition = "follow_bar";
          hideWallpaperFilenames = true;
          viewMode = "single";
          sortOrder = "name";

          transitionType = "random";
          transitionDuration = 1500;
          transitionEdgeSmoothness = 0.05;
          skipStartupTransition = false;

          overviewEnabled = false;
          useSolidColor = false;
          useWallhaven = false;
        };

        bar = {
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

                displayMode = "alwaysShow";
                hideIfIdle = false;
                hideIfNotDetected = true;
                showNoctaliaPerformance = false;
                showPowerProfiles = false;
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
      };
    };
  };
}
