{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  current-age = pkgs.stdenv.mkDerivation {
    name = "current-age";
    propagatedBuildInputs = [(pkgs.python3.withPackages (p: [p.python-dateutil]))];
    dontUnpack = true;
    installPhase = "install -Dm755 ${../../../files/scripts/current_age.py} $out/bin/current-age";
  };
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings.exec-once = [
      "${config.programs.waybar.package}/bin/waybar"
    ];

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
              "power-profiles-daemon"
            ]
            ++ lib.optional config.setup.isLaptop "battery"
            ++ [
              "custom/power"
            ];

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

          "custom/current-age" = {
            format = "{}";
            exec = "${current-age}/bin/current-age";
            interval = 1;
          };

          pulseaudio = {
            format = "{icon} {volume}%";
            format-icons = {
              default = ["" "" ""];
            };
            on-click = "${pkgs.pavucontrol}/bin/pavucontrol";
            on-click-right = "${pkgs.wireplumber}/bin/wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle";
            format-muted = " {volume}%";
          };
        }
      ];
    };
  };
}
