{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  timew-start =
    let
      app = pkgs.writeShellApplication {
        name = "timew-start";
        runtimeInputs = [
          pkgs.timewarrior
          pkgs.gawk
          config.programs.wofi.package
        ];

        text = ''
          tags="$(timew tags :all | awk 'NR > 3 {if ($0 != "") print $1;}')"

          choice="$(printf 'stop\ncancel\n%s' "$tags" | wofi --show=dmenu --cache-file=/dev/null)"

          case "$choice" in
              stop)
                  timew stop
                  ;;
              cancel)
                  timew cancel
                  ;;
              *)
                  # shellcheck disable=SC2086 # We want word splitting here
                  timew start $choice
                  ;;
          esac
        '';
      };
    in
    "${app}/bin/timew-start";

  timew-waybar =
    let
      app = pkgs.writeShellApplication {
        name = "timew-waybar";
        runtimeInputs = [
          pkgs.timewarrior
          pkgs.gawk
        ];

        text = ''
          tags="$(timew | awk '$1 == "Tracking" {print substr($0, 10);}')"

          time="$(timew | awk '$1 == "Total" {print $2;}')"
          time="''${time#0:}"
          time="''${time#0}"

          echo "$time $tags"
        '';
      };
    in
    "${app}/bin/timew-waybar";
in
{
  options.setup.shared.timewarrior-waybar-module = lib.mkOption {
    description = "The full waybar module for timewarrior integration";
    type = lib.types.attrs;
    default = { };
  };

  config =
    lib.mkIf
      (osConfig.setup.desktopEnvironments.hyprland.enable && config.setup.misc.programs.timewarrior)
      {
        wayland.windowManager.hyprland.settings = {
          bind = [ "$mod, Z, exec, ${timew-start}" ];
        };

        setup.shared.timewarrior-waybar-module = {
          format = " {}";
          exec = timew-waybar;

          interval = 1;
          tooltip = false;

          on-click = timew-start;
          on-click-right = "${lib.getExe pkgs.timewarrior} stop";
        };
      };
}
