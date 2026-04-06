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
            "${lib.getExe config.programs.noctalia-shell.package} ipc call lockScreen lock"
          else if config.programs.hyprlock.enable then
            lib.getExe pkgs.hyprlock
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
