{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  optSet = cond: path:
    if cond
    then "set_date_formats(\"${path}\")"
    else "";
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.set-servarr-date-formats = {
      description = "Set the time and date formats for servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "set_servarr_date_formats.py" {}
          ''
            import os
            import sqlite3

            CONFIG_PAIRS = [
                ("calendarweekcolumnheader", "ddd DD/MM"),
                ("shortdateformat", "DD MMM YYYY"),
                ("longdateformat", "dddd, D MMMM YYYY"),
                ("timeformat", "h(:mm)a"),
            ]


            def set_date_formats(db_path: str) -> None:
                if not os.path.exists(db_path):
                    raise RuntimeError(f"Database at {db_path} doesn't exist")

                conn = sqlite3.connect(db_path)
                cur = conn.cursor()

                for key, value in CONFIG_PAIRS:
                    if (
                        len(
                            cur.execute(
                                f"SELECT * FROM Config WHERE Key == '{key}'"
                            ).fetchmany()
                        ) > 0
                    ):
                        continue

                    cur.execute(
                        f"INSERT INTO Config (Key, Value) VALUES ('{key}', '{value}')"
                    )

                conn.commit()


            def main() -> None:
                set_date_formats("/var/lib/prowlarr/prowlarr.db")
                ${optSet cfgMs.books "${config.services.readarr.dataDir}/readarr.db"}
                ${optSet cfgMs.music "${config.services.lidarr.dataDir}/lidarr.db"}
                ${optSet cfgMs.movies "${config.services.radarr.dataDir}/radarr.db"}
                ${optSet cfgMs.telly "${config.services.sonarr.dataDir}/sonarr.db"}


            if __name__ == '__main__':
                main()
          ''}";
      };
    };
  };
}
