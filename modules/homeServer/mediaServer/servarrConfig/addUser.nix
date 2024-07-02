{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  optWrite = cond: path:
    if cond
    then "write_user_to_database(\"${path}\")"
    else "";
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.add-user-to-servarr-apps = {
      description = "Add the user 'dyson' to all the servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "add_user_to_servarr_apps.py" {flakeIgnore = ["E501"];}
          ''
            import os
            import sqlite3
            import uuid

            PASSWORD = "ZsMvdA5/z4lu+V8URbBzLbUHGfC+4fKAANWNZImxr/c="
            SALT = "DFNd/zuv18QMhpSFCZfcaQ=="

            READARR_PASSWORD = "5e884898da28047151d0e56f8dc6292773603d0d6aabbdd62a11ef721d1542d8"


            def write_user_to_database(db_path: str) -> None:
                if not os.path.exists(db_path):
                    raise RuntimeError(f"Database at {db_path} doesn't exist")

                conn = sqlite3.connect(db_path)
                cur = conn.cursor()

                # If the user is already in the database, then we don't need to insert it
                if (
                    len(
                        cur.execute(
                            "SELECT * FROM Users WHERE Username == 'dyson'"
                        ).fetchmany()
                    ) > 0
                ):
                    return

                identifier = str(uuid.uuid4())
                service_name = db_path.split("/")[-1].strip(".db").lower()

                if service_name == "readarr" or service_name == "speakarr":
                    cur.execute(
                        "INSERT INTO Users (Identifier, Username, Password) VALUES "
                        f"('{identifier}', 'dyson', '{READARR_PASSWORD}')"
                    )
                else:
                    cur.execute(
                        "INSERT INTO Users (Identifier, Username, Password, Salt, Iterations) "
                        f"VALUES ('{identifier}', 'dyson', '{PASSWORD}', '{SALT}', 10000)"
                    )

                conn.commit()


            def main() -> None:
                write_user_to_database("/var/lib/prowlarr/prowlarr.db")
                ${optWrite cfgMs.books "${config.services.readarr.dataDir}/readarr.db"}
                ${optWrite cfgMs.books "${config.services.speakarr.dataDir}/speakarr.db"}
                ${optWrite cfgMs.music "${config.services.lidarr.dataDir}/lidarr.db"}
                ${optWrite cfgMs.movies "${config.services.radarr.dataDir}/radarr.db"}
                ${optWrite cfgMs.telly "${config.services.sonarr.dataDir}/sonarr.db"}


            if __name__ == '__main__':
                main()
          ''}";
      };
    };
  };
}
