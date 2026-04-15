{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.misc.services.bedtimeLock {
    systemd.user = {
      services.bedtime-lock = {
        Unit = {
          Description = "Bedtime lock";
          Type = "oneshot";
        };

        Service.ExecStart =
          if config.programs.noctalia-shell.enable then
            lib.getExe (
              pkgs.writeShellApplication {
                name = "bedtime-lock-noctalia";
                runtimeInputs = [ config.programs.noctalia-shell.package ];

                text = ''
                  noctalia-shell ipc call media pause
                  noctalia-shell ipc call lockScreen lock
                '';
              }
            )
          else if config.programs.hyprlock.enable then
            lib.getExe (
              pkgs.writeShellApplication {
                name = "bedtime-lock-hyprlock";
                runtimeInputs = [
                  pkgs.playerctl
                  config.programs.hyprlock.package
                ];

                text = ''
                  playerctl pause
                  hyprlock
                '';
              }
            )
          else
            (abort "No known locking program");
      };

      timers.bedtime-lock = {
        Install.WantedBy = [ "timers.target" ];

        Timer = {
          OnCalendar = "*-*-* 01..06:00/10:00";
          Unit = "bedtime-lock.service";
          Persistent = false;
        };
      };
    };
  };
}
