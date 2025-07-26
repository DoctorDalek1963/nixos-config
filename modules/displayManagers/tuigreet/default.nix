{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfgDmSd = config.services.displayManager.sessionData;
in
{
  config = lib.mkIf config.setup.displayManagers.tuigreet.enable {
    setup.impermanence.keepDirs = [ "/var/cache/tuigreet" ];

    services.greetd = {
      enable = true;
      vt = 2;

      settings.default_session.command = builtins.concatStringsSep " " [
        "${pkgs.greetd.tuigreet}/bin/tuigreet"
        "--sessions ${cfgDmSd.desktops}/share/wayland-sessions"
        "--xsessions ${cfgDmSd.desktops}/share/xsessions"
        "--xsession-wrapper ${cfgDmSd.wrapper}"
        "--time"
        "--time-format '%-I:%M:%S %p, %A %-d %B 12,0%y'"
        "--greeting 'NixOS ${config.system.nixos.label}'"
        "--remember"
        "--remember-user-session"
        "--window-padding 3"
        "--prompt-padding 0"
        "--asterisks"
        "--theme '${
          lib.concatMapAttrsStringSep ";" (name: value: "${name}=${value}") {
            time = "magenta";
            title = "red";
            greet = "green";
            prompt = "cyan";
          }
        }'"
      ];
    };
  };
}
