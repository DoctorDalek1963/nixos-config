{ inputs, ... }:
{
  flake-file.inputs = {
    noctalia = {
      url = "github:noctalia-dev/noctalia-shell";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  flake.aspects.noctalia.homeManager =
    {
      pkgs,
      lib,
      config,
      osConfig,
      ...
    }:
    {
      imports = [
        inputs.noctalia.homeModules.default
      ];

      impermanence.directories = [
        ".cache/noctalia"
      ];

      # TODO: Remove config.setup
      programs.noctalia-shell =
        let
          ipc = "${lib.getExe config.programs.noctalia-shell.package} ipc";

          useUwsm = config.wayland.windowManager.hyprland.enable && osConfig.programs.hyprland.withUWSM;
        in
        {
          enable = true;

          package = pkgs.noctalia-shell.override {
            bluetoothSupport = osConfig.setup.isLaptop;
            brightnessctlSupport = true;
            cliphistSupport = true;
            ddcutilSupport = true;
            wlsunsetSupport = false;
            wl-clipboardSupport = true;
            wlr-randrSupport = true;
            imagemagickSupport = true;
            calendarSupport = false;
          };

          settings = {
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

              lowUrgencyDuration = 8;
              normalUrgencyDuration = 15;
              criticalUrgencyDuration = 30;
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
                      action = "logout";
                      keybind = "3";

                      command =
                        if useUwsm then
                          "${lib.getExe osConfig.programs.uwsm.package} stop"
                        else if config.wayland.windowManager.hyprland.enable then
                          "${lib.getExe pkgs.hyprshutdown} -t 'Logging out...'"
                        else
                          "";
                    }
                    {
                      action = "reboot";
                      keybind = "4";

                      command =
                        if config.wayland.windowManager.hyprland.enable then
                          "${lib.getExe pkgs.hyprshutdown} -t 'Rebooting...' -p '/run/current-system/sw/bin/systemctl reboot'"
                        else
                          "";
                    }
                    {
                      action = "shutdown";
                      keybind = "5";

                      command =
                        if config.wayland.windowManager.hyprland.enable then
                          "${lib.getExe pkgs.hyprshutdown} -t 'Shutting down...' -p '/run/current-system/sw/bin/systemctl poweroff'"
                        else
                          "";
                    }
                    {
                      action = "rebootToUefi";
                      keybind = "6";

                      command =
                        if config.wayland.windowManager.hyprland.enable then
                          "${lib.getExe pkgs.hyprshutdown} -t 'Rebooting to UEFI...' -p '/run/current-system/sw/bin/systemctl reboot --firmware-setup'"
                        else
                          "";
                    }

                    {
                      action = "hibernate";
                      enabled = false;
                    }
                    {
                      action = "userspaceReboot";
                      enabled = false;
                    }
                  ];
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
              panelBackgroundOpacity = 0.7;
              settingsPanelMode = "attached";
              boxBorderEnabled = true;
              tooltipsEnabled = true;
            };
          };
        };
    };
}
