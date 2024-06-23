{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  optAdd = cond: path:
    if cond
    then "add_transmission(\"${path}\")"
    else "";
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.add-transmission-to-servarr-apps = {
      description = "Add the Transmission torrent client to all the servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "add_transmission_to_servarr_apps.py" {}
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
                "readarr": {"musicCategory": "books"},
                "lidarr": {"musicCategory": "music"},
                "radarr": {"movieCategory": "movies"},
                "sonarr": {"tvCategory": "telly"},
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
                ${optAdd cfgMs.books "${config.services.readarr.dataDir}/readarr.db"}
                ${optAdd cfgMs.music "${config.services.lidarr.dataDir}/lidarr.db"}
                ${optAdd cfgMs.movies "${config.services.radarr.dataDir}/radarr.db"}
                ${optAdd cfgMs.telly "${config.services.sonarr.dataDir}/sonarr.db"}


            if __name__ == '__main__':
                main()
          ''}";
      };
    };
  };
}
