{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${config.programs.waybar.package}/bin/waybar"
    ];

    home.packages = [pkgs.power-profiles-daemon];

    programs.waybar = {
      enable = true;

      settings = [
        {
          layer = "top";
          position = "top";
          reload_style_on_change = true;

          modules-left = ["hyprland/workspaces" "hyprland/window"];
          modules-center = [
            # The builtin clock module doesn't support stripping leading zeroes
            # for some bizarre reason
            "custom/clock"
          ];
          modules-right =
            [
              "tray"
              "custom/current-age"
              "idle_inhibitor"
              "pulseaudio"
              "network"
            ]
            ++ lib.optional osConfig.setup.hasBluetooth "bluetooth"
            ++ [
              "power-profiles-daemon"
            ]
            ++ lib.optional osConfig.setup.isLaptop "battery"
            ++ [
              "custom/power"
            ];

          "hyprland/window" = {
            format = "{}";
            max-length = 35;
            icon = true;
          };

          "custom/clock" = {
            format = "{}";
            exec = ''${pkgs.coreutils}/bin/date +"%-I:%M:%S %p, %A %d %B 12,0%y"'';
            interval = 1;
          };

          tray = {
            icon-size = 20;
            spacing = 10;
            show-passive-items = true;
          };

          "custom/current-age" = let
            current-age = pkgs.stdenv.mkDerivation {
              name = "current-age";
              propagatedBuildInputs = [(pkgs.python3.withPackages (p: [p.python-dateutil]))];
              dontUnpack = true;
              installPhase = "install -Dm755 ${./current_age.py} $out/bin/current-age";
            };
          in {
            format = "󰃮 {}";
            exec = "${current-age}/bin/current-age";
            interval = 1;
          };

          idle_inhibitor = {
            format = "{icon}";
            format-icons = {
              activated = " ";
              deactivated = " ";
            };
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-icons = {
              default = ["" "" " "];
              default-muted = " ";
            };

            ignored-sinks = ["Easy Effects Sink"];
            max-volume = 150;
            scroll-step = 5;

            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
          };

          network = {
            format-wifi = "󰖩 {ifname}";
            format-ethernet = "󰈀 {ifname}";
            format-disconnected = "󰖪 {ifname}";
          };

          bluetooth = {};

          "custom/power" = {
            "format" = "{icon}";
            "format-icons" = "";
            "exec-on-event" = "true";
            # "on-click" = "TODO: Make power button script";
            "tooltip-format" = "Power menu";
          };
        }
      ];

      style = let
        font-size =
          if osConfig.setup.isLaptop
          then "16px"
          else "14px";
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
              color: @pink;
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

          #pulseaudio {
              color: @maroon;
          }

          #pulseaudio.muted {
              color: @text;
          }

          #network {
              color: @yellow;
          }

          #bluetooth {
              color: @teal;
          }

          #power-profiles-daemon {
              color: @sapphire;
          }

          #battery {
              color: @yellow;
          }

          #custom-power {
              color: @red;
          }

          #battery.charging, #battery.plugged {
              color: @sapphire;
          }

          /* Flash text in battery section when low and not charging */
          @keyframes blink {
              to {
                  color: @red;
              }
          }
          #battery.critical:not(.charging) {
              background-color: @maroon;

              /* Using steps() instead of linear as a timing function to limit cpu usage */
              animation-name: blink;
              animation-duration: 0.5s;
              animation-timing-function: steps(12);
              animation-iteration-count: infinite;
              animation-direction: alternate;
          }
        '';
    };
  };
}
