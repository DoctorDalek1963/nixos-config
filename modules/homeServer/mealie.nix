{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
in
{
  config = lib.mkIf (cfg.enable && cfg.mealie.enable) {
    setup = {
      impermanence.keepDirs = [
        {
          directory = "/var/lib/mealie";
          user = "mealie";
          group = "mealie";
          mode = "u=rwx,g=rx,o=rx";
        }
      ];
      backup.paths = [ "/var/lib/mealie" ];
    };

    services.mealie = {
      enable = true;
      port = cfg.ports.mealie;

      # Use PostgreSQL instead of SQLite
      database.createLocally = true;

      settings = {
        PUID = config.users.users.mealie.uid;
        PGID = config.users.groups.mealie.gid;
      };
    };

    systemd.services = {
      mealie.serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "mealie";

        StateDirectory = "mealie";
        WorkingDirectory = lib.mkForce "/var/lib/mealie";

        TimeoutStartSec = "30 min";
        RestartSec = "15s";
        Restart = "always";

        AmbientCapabilities = [
          "CAP_SETUID"
          "CAP_SETGID"
        ];
        CapabilityBoundingSet = [
          "CAP_SETUID"
          "CAP_SETGID"
        ];
      };

      # Don't notify Mealie when Postgres fails to start
      postgresql.serviceConfig.RestartMode = "direct";
    };

    users = {
      users = {
        mealie = {
          description = "Mealie recipe manager";
          group = "mealie";
          isSystemUser = true;
        };
      };

      groups.mealie = { };
    };
  };
}
