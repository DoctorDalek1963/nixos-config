{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  optAdd = cond: path: if cond then "add_transmission(\"${path}\")" else "";
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.add-transmission-to-servarr-apps = {
      description = "Add the Transmission torrent client to all the servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "add_transmission_to_servarr_apps.py"
          {
            flakeIgnore = [
              "W293"
              "W503"
              "E303"
            ];
          }
          ''
            import json
            import os
            import sqlite3

            SETTINGS = {
                "host": "192.168.${toString cfgMs.transmission.thirdOctet}.2",
                "port": ${toString cfg.ports.mediaServer.transmission},
                "useSsl": False,
                "urlBase": "/transmission/",
                "priority": 1,
                "addPaused": False,
            }

            SPECIFIC_SETTINGS = {
                # Yes, Readarr does actually use "musicCategory" for its books
                # (as of 0.3.26.2526)
                "readarr": {"musicCategory": "ebooks"},
                "speakarr": {"musicCategory": "audiobooks"},
                "lidarr": {"musicCategory": "music"},
                "radarr": {"movieCategory": "movies"},
                "sonarr": {"tvCategory": "telly"},
                "whisparr": {"tvCategory": "porn"},
            }


            def add_transmission(db_path: str) -> None:
                if not os.path.exists(db_path):
                    raise RuntimeError(f"Database at {db_path} doesn't exist")

                conn = sqlite3.connect(db_path)
                cur = conn.cursor()

                if (
                    len(
                        cur.execute(
                            "SELECT * FROM DownloadClients WHERE Name == 'Transmission'"
                        ).fetchmany()
                    )
                    > 0
                ):
                    return

                service_name = db_path.split("/")[-1].strip(".db").lower()

                if service_name in SPECIFIC_SETTINGS.keys():
                    settings = SETTINGS | SPECIFIC_SETTINGS[service_name]
                else:
                    settings = SETTINGS

                cur.execute(
                    "INSERT INTO DownloadClients (Enable, Name, Implementation, "
                    "Settings, ConfigContract, Priority) VALUES (1, 'Transmission', "
                    f"'Transmission', '{json.dumps(settings)}', 'TransmissionSettings', 1)"
                )
                conn.commit()


            def main() -> None:
                add_transmission("/var/lib/prowlarr/prowlarr.db")
                ${optAdd config.services.readarr.enable "${config.services.readarr.dataDir}/readarr.db"}
                ${optAdd config.services.speakarr.enable "${config.services.speakarr.dataDir}/speakarr.db"}
                ${optAdd config.services.lidarr.enable "${config.services.lidarr.dataDir}/lidarr.db"}
                ${optAdd config.services.radarr.enable "${config.services.radarr.dataDir}/radarr.db"}
                ${optAdd config.services.sonarr.enable "${config.services.sonarr.dataDir}/sonarr.db"}
                ${optAdd config.services.whisparr.enable "${config.services.whisparr.dataDir}/whisparr2.db"}


            if __name__ == '__main__':
                main()
          ''
        }";
      };
    };
  };
}
