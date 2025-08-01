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

    # Disable systemd status logging on /dev/console before launching tuigreet
    # and re-enable it afterwards. See the following:
    # https://unix.stackexchange.com/a/796531
    # https://www.man7.org/linux/man-pages/man1/systemd.1.html
    # https://www.man7.org/linux/man-pages/man5/org.freedesktop.systemd1.5.html
    systemd.services.greetd.serviceConfig =
      let
        dbusCmd =
          arg:
          lib.concatStringsSep " " [
            "/run/current-system/sw/bin/busctl"
            "call"
            "org.freedesktop.systemd1"
            "/org/freedesktop/systemd1"
            "org.freedesktop.systemd1.Manager"
            "SetShowStatus"
            "s"
            arg
            "--expect-reply=yes"
          ];
      in
      {
        ExecStartPre = [ (dbusCmd "0") ];
        ExecStopPost = [ (dbusCmd "1") ];
      };
  };
}
