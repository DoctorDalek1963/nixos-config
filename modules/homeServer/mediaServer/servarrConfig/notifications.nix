{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfg.ntfy.enable) {
    systemd.services.set-servarr-notifications = {
      description = "Setup the notifications systems for Servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "set_servarr_notifications.py" {}
          ''
            import json
            import os
            import sqlite3
            import typing

            PROWLARR_DB_PATH = "/var/lib/prowlarr/prowlarr.db"


            def make_settings(
                topics: list[str], tags: list[str], priority: int = 3
            ) -> dict[str, typing.Any]:
                return {
                  "serverUrl": "https://localhost:${toString cfg.ports.ntfy.https}",
                  "priority": priority,
                  "topics": topics,
                  "tags": tags,
                }


            def make_prowlarr_settings(
                topic: str, tag: str, priority: int = 3
            ) -> dict[str, typing.Any]:
                return make_settings([f"prowlarr-{topic}"], [tag], priority)


            def set_prowlarr_ntfy() -> None:
                if not os.path.exists(PROWLARR_DB_PATH):
                    raise RuntimeError(f"Database at {PROWLARR_DB_PATH} doesn't exist")

                conn = sqlite3.connect(PROWLARR_DB_PATH)
                cur = conn.cursor()

                cur.execute("DELETE FROM Notifications")

                settings = make_prowlarr_settings("health", "ambulance")
                cur.execute(
                    "INSERT INTO Notifications (Name, Settings, Implementation, "
                    "ConfigContract, Tags, OnHealthIssue, IncludeHealthWarnings, "
                    "OnApplicationUpdate, OnGrab, IncludeManualGrabs, OnHealthRestored) "
                    f"VALUES ('ntfy (health issues)', '{json.dumps(settings)}', "
                    "'Ntfy', 'NtfySettings', '[]', 1, 1, 0, 0, 0, 0)"
                )

                settings = make_prowlarr_settings("health", "+1")
                cur.execute(
                    "INSERT INTO Notifications (Name, Settings, Implementation, "
                    "ConfigContract, Tags, OnHealthIssue, IncludeHealthWarnings, "
                    "OnApplicationUpdate, OnGrab, IncludeManualGrabs, OnHealthRestored) "
                    f"VALUES ('ntfy (health restored)', '{json.dumps(settings)}', "
                    "'Ntfy', 'NtfySettings', '[]', 0, 0, 0, 0, 0, 1)"
                )

                settings = make_prowlarr_settings("grabs", "inbox_tray")
                cur.execute(
                    "INSERT INTO Notifications (Name, Settings, Implementation, "
                    "ConfigContract, Tags, OnHealthIssue, IncludeHealthWarnings, "
                    "OnApplicationUpdate, OnGrab, IncludeManualGrabs, OnHealthRestored) "
                    f"VALUES ('ntfy (grabs)', '{json.dumps(settings)}', "
                    "'Ntfy', 'NtfySettings', '[]', 0, 0, 0, 1, 1, 0)"
                )

                conn.commit()


            def main() -> None:
                set_prowlarr_ntfy()


            if __name__ == '__main__':
                main()
          ''}";
      };
    };
  };
}
