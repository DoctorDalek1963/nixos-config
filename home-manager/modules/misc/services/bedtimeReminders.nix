{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.misc.services.bedtimeReminders {
    systemd.user = {
      services.bedtime-reminders = {
        Unit = {
          Description = "Bedtime reminders";
          Type = "oneshot";
        };

        Service.ExecStart = pkgs.writeShellScript "bedtime-reminder" ''
          ${lib.getExe' pkgs.libnotify "notify-send"} --urgency=critical --app-name=Bedtime "Go to bed now"
        '';
      };

      timers.bedtime-reminders = {
        Install.WantedBy = [ "timers.target" ];

        Timer = {
          OnCalendar = "*-*-* 00..06:00/2:00";
          Unit = "bedtime-reminders.service";
          Persistent = false;
        };
      };
    };
  };
}
