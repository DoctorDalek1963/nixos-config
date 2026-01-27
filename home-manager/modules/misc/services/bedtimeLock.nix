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

        Service.ExecStart = lib.getExe pkgs.hyprlock;
      };

      timers.bedtime-lock = {
        Install.WantedBy = [ "timers.target" ];

        Timer = {
          OnCalendar = "Mon..Fri *-*-* 01..06:00/10:00";
          Unit = "bedtime-lock.service";
          Persistent = false;
        };
      };
    };
  };
}
