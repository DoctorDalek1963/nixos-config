{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  launch-btop = lib.mkIf config.setup.terminal.tools.btop.enable "${
    config.wayland.windowManager.hyprland.settings."$launchInTerminal"
  } ${config.programs.btop.package}/bin/btop";

  hyprctl = "${config.wayland.windowManager.hyprland.package}/bin/hyprctl";
  hyprctl-exit = "${hyprctl} dispatch exit";

  zenity-confirm =
    actionName: command:
    ''if ${pkgs.zenity}/bin/zenity --question --title="${actionName}" --text="Are you sure you want to ${lib.toLower actionName}?" --default-cancel; then ${command}; fi'';
in
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${config.programs.waybar.package}/bin/waybar"
    ];

    systemd.user.services.playerctld = {
      Unit = {
        Description = "playerctl daemon";
        After = [ "graphical-session.target" ];
      };
      Install.WantedBy = [ "default.target" ];

      Service = {
        Type = "simple";
        ExecStart = "${pkgs.playerctl}/bin/playerctld";

        Restart = "on-failure";
        RestartSec = "5s";
      };
    };

    programs.waybar = {
      enable = true;

      # See https://github.com/Alexays/Waybar/wiki
      settings = [
        {
          layer = "top";
          position = "top";
          reload_style_on_change = true;

          modules-left = [
            "hyprland/workspaces"
            # "group/stats"
            "cpu"
            "memory"
          ]
          ++ lib.optional config.setup.misc.programs.timewarrior "custom/timewarrior"
          ++ [
            "hyprland/window"
          ];

          modules-center = [
            # The builtin clock module doesn't support stripping leading zeroes
            # for some bizarre reason
            "custom/clock"
          ];

          modules-right = [
            "tray"
            "custom/current-age"
          ]
          ++ lib.optional config.services.hypridle.enable "idle_inhibitor"
          ++ [
            "group/audio"
            "network"
          ]
          ++ lib.optional osConfig.setup.hasBluetooth "bluetooth"
          ++ lib.optional osConfig.setup.isLaptop "battery"
          ++ [
            "group/power"
          ];

          "hyprland/workspaces" = { };

          # "group/stats" = {
          #   orientation = "inherit";
          #   drawer = {
          #     transition-duration = 250;
          #     children-class = "group-stats-child";
          #     transition-left-to-right = true;
          #   };
          #   modules = [
          #     "cpu"
          #     "temperature"
          #     "memory"
          #   ];
          # };

          cpu = {
            format = " {usage}%";
            interval = 5;

            on-click = launch-btop;
          };

          # temperature = let
          #   # Use `sensors` and the below bash command to find the right
          #   # temperature sensor that agrees with btop
          #   # for i in /sys/class/hwmon/hwmon*/temp*_input; do echo "$(<$(dirname $i)/name): $(cat ${i%_*}_label 2>/dev/null || echo $(basename ${i%_*})) $(readlink -f $i)"; done
          #   hwmon-path-map = {
          #     "Alex-NixOS" = "/sys/class/hwmon/hwmon1/temp1_input";
          #     "Harold-NixOS" = "/sys/class/hwmon/hwmon4/temp1_input";
          #   };
          # in {
          #   hwmon-path =
          #     lib.mkIf
          #     (hwmon-path-map ? "${osConfig.setup.hostname}")
          #     hwmon-path-map."${osConfig.setup.hostname}";
          #
          #   format = " {temperatureC}°C";
          #   tooltip = false;
          #   interval = 5;
          #
          #   on-click = launch-btop;
          # };

          memory = {
            format = "  {percentage}%";
            tooltip-format = "{used:0.1f}GiB / {total:0.1f}GiB used ({swapUsed:0.1f}GiB / {swapTotal:0.1f}GiB swap)";

            on-click = launch-btop;
          };

          "custom/timewarrior" =
            lib.mkIf config.setup.misc.programs.timewarrior config.setup.shared.timewarrior-waybar-module;

          "hyprland/window" = {
            format = "{title}";
            max-length = 50;
            icon = true;
            on-click = "${hyprctl} dispatch fullscreen 1";
            on-click-right = "${hyprctl} dispatch killactive";
          };

          "custom/clock" = {
            format = "{}";
            exec = ''${pkgs.coreutils}/bin/date +"%-I:%M:%S %p, %A %-d %B 12,0%y"'';
            interval = 1;
            tooltip = false;
          };

          tray = {
            icon-size = 20;
            spacing = 10;
            show-passive-items = true;
          };

          "custom/current-age" =
            let
              current-age = pkgs.stdenv.mkDerivation {
                name = "current-age";
                propagatedBuildInputs = [ (pkgs.python3.withPackages (p: [ p.python-dateutil ])) ];
                dontUnpack = true;
                installPhase = "install -Dm755 ${./current_age.py} $out/bin/current-age";
              };
            in
            {
              format = "󰃮 {}";
              exec = "${current-age}/bin/current-age";
              interval = 1;
              tooltip-format = "Current age";
            };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
            tooltip-format-activated = "Inhibiting idle";
            tooltip-format-deactivated = "Not inhibiting idle";
          };

          "group/audio" = {
            orientation = "inherit";
            drawer = {
              transition-duration = 250;
              children-class = "group-audio-child";
              transition-left-to-right = false;
            };
            modules = [
              "pulseaudio"
              "mpris"
            ];
          };

          mpris = {
            format = "{player_icon} {status_icon} {dynamic}";
            format-stopped = "";

            player-icons = {
              default = "󰝚";
              firefox = "";
            };
            status-icons = {
              playing = "";
              paused = "";
            };

            dynamic-order = [
              "title"
              "artist"
              "album"
            ];
            dynamic-separator = " – "; # En dash
            dynamic-len = -1;

            title-len = 30;
            artist-len = 15;
            album-len = 25;

            # Use full dynamic format in tooltip
            tooltip-format = "{player_icon} {dynamic}";
            enable-tooltip-len-limits = false;

            player = "playerctld";

            # Skip forward and back by 10 seconds
            on-scroll-up = "${lib.getExe pkgs.playerctl} position 10+";
            on-scroll-down = "${lib.getExe pkgs.playerctl} position 10-";
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-icons = {
              default = [
                ""
                ""
                " "
              ];
              default-muted = " ";
            };

            ignored-sinks = [ "Easy Effects Sink" ];
            max-volume = 150;
            scroll-step = 5;

            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          network = {
            format-wifi = "󰖩 {essid} ({signalStrength}%)";
            format-ethernet = "󰈀 Wired";
            format-disconnected = "󰖪 No internet";
            tooltip-format = "{bandwidthUpBytes} 󰜷 {bandwidthDownBytes} 󰜮 ({ipaddr}/{cidr} on {ifname})";

            on-click = "${pkgs.networkmanagerapplet}/bin/nm-connection-editor";
            on-click-right = config.setup.terminal.shellAliases.resetwifi;
          };

          bluetooth = lib.mkIf osConfig.setup.hasBluetooth {
            format = "󰂯 {status}";
            format-disabled = "󰂯 Disabled";
            format-on = "󰂯 On";
            format-off = "󰂯 Off";
            format-connected = "󰂯 {device_alias}";
            format-connected-battery = "󰂯 {device_alias} {device_battery_percentage}%";

            on-click = "${pkgs.blueberry}/bin/blueberry";
          };

          battery = {
            format = "{icon} {capacity}%";
            format-icons = [
              "󰂎"
              "󰁻"
              "󰁽"
              "󰁿"
              "󰂁"
              "󰁹"
            ];

            format-charging = "󱐋{icon} {capacity}%";
            format-full = "󰚥 {capacity}%";

            states = {
              high = 100;
              moderate = 65;
              warning = 30;
              critical = 15;
            };
          };

          "group/power" = {
            orientation = "inherit";
            drawer = {
              transition-duration = 250;
              children-class = "group-power-child";
              transition-left-to-right = false;
            };
            modules = [
              "custom/power"
              "custom/logout"
              "custom/lock"
              "custom/reboot"
            ];
          };

          "custom/power" = {
            format = "";
            tooltip-format = "Shutdown";
            on-click = zenity-confirm "Shutdown" "${hyprctl-exit}; /run/current-system/sw/bin/shutdown now";
          };

          "custom/logout" = {
            format = "󰍃";
            tooltip-format = "Logout";
            on-click = zenity-confirm "Logout" hyprctl-exit;
          };

          "custom/lock" = {
            format = "󰌾";
            tooltip-format = "Lock";
            on-click = "${config.programs.hyprlock.package}/bin/hyprlock";
          };

          "custom/reboot" = {
            format = "";
            tooltip-format = "Reboot";
            on-click = zenity-confirm "Reboot" "${hyprctl-exit}; /run/current-system/sw/bin/reboot";
          };
        }
      ];

      style =
        let
          font-size = if osConfig.setup.isLaptop then "16px" else "14px";
        in
        # css
        ''
          @define-color rosewater #f4dbd6;
          @define-color flamingo #f0c6c6;
          @define-color pink #f5bde6;
          @define-color mauve #c6a0f6;
          @define-color red #ed8796;
          @define-color maroon #ee99a0;
          @define-color peach #f5a97f;
          @define-color yellow #eed49f;
          @define-color green #a6da95;
          @define-color teal #8bd5ca;
          @define-color sky #91d7e3;
          @define-color sapphire #7dc4e4;
          @define-color blue #8aadf4;
          @define-color lavender #b7bdf8;

          @define-color text #cad3f5;
          @define-color subtext1 #b8c0e0;
          @define-color subtext0 #a5adcb;
          @define-color overlay2 #939ab7;
          @define-color overlay1 #8087a2;
          @define-color overlay0 #6e738d;
          @define-color surface2 #5b6078;
          @define-color surface1 #494d64;
          @define-color surface0 #363a4f;
          @define-color base #24273a;
          @define-color mantle #1e2030;
          @define-color crust #181926;

          * {
              font-family: "Arimo Nerd Font", Arial, Helvetica, sans-serif;
              font-size: ${toString font-size};
              font-weight: 600;

              /* We don't want whatever the default padding and margins are because we set our own */
              padding: 0;
              margin: 0;
          }

          window#waybar {
              background-color: @crust;
              transition-property: background-color;
              transition-duration: .5s;
          }

          /* Keep them off the edges of the screen */
          .modules-left, .modules-right {
              padding: 0 10px;
          }

          .modules-center {
              padding: 0;
          }

          .module {
              background-color: @surface0;
              border-radius: 12px;
              margin: 5px 5px;
              padding: 3px 8px;
          }

          #workspaces > button {
              padding: 0 5px;
              color: @yellow;
          }

          #workspaces > button.active {
              color: @sapphire;
          }

          /* Make the font of workspace buttons bigger and underline the current one */
          #workspaces > button > box > label {
              font-size: 1.2rem;
          }
          #workspaces > button.active > box > label {
              text-decoration: underline;
          }

          #window {
              color: @pink;
          }

          /* Hide window section when no window is open on the current desktop */
          window#waybar.empty #window {
              background-color: transparent;
          }

          #custom-timewarrior {
              color: @sapphire;
          }

          #custom-clock {
              color: @pink;
          }

          #tray {}

          #custom-current-age {
              color: @sapphire;
          }

          #idle_inhibitor {
              color: @mauve;
          }

          #mpris {
              color: @green;
          }

          #mpris.paused {
              color: @teal;
          }

          #pulseaudio {
              color: @maroon;
          }

          #pulseaudio.muted {
              color: @teal;
          }

          #network {
              color: @yellow;
          }

          #bluetooth {
              color: @teal;
          }

          #cpu {
              color: @pink;
          }

          #memory {
              color: @teal;
          }

          #temperature {
              color: @maroon;
          }

          #battery.high {
              color: @green;
          }
          #battery.moderate {
              color: @yellow;
          }
          #battery.warning {
              color: @peach;
          }

          /* Flash text in battery section when critical and not charging */
          @keyframes blink {
              to {
                  background-color: @red;
              }
          }
          #battery.critical:not(.charging) {
              color: @text;
              /* Using steps() instead of linear as a timing function to limit cpu usage */
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: steps(6);
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }

          #battery.charging, #battery.plugged {
              color: @sapphire;
          }

          #custom-power {
              color: @red;
          }
          #custom-logout {
              color: @teal;
          }
          #custom-lock {
              color: @yellow;
          }
          #custom-reboot {
              color: @pink;
          }
        '';
    };
  };
}
