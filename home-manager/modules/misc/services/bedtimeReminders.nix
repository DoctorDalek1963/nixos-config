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

        Install = {
          WantedBy = [ "default.target" ];
        };

        Service = {
          ExecStart = pkgs.writeShellScript "bedtime-reminder" ''
            ${pkgs.dunst}/bin/dunstify "Bedtime" "Go to bed now" --urgency=critical
          '';
        };
      };

      timers.bedtime-reminders = {
        Install = {
          WantedBy = [ "timers.target" ];
        };

        Timer = {
          OnCalendar = "*-*-* 00..06:00/5:00";
          Unit = "bedtime-reminders.service";
        };
      };
    };
  };
}
