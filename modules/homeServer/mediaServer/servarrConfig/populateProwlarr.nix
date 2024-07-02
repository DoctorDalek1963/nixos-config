{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  optStr = cond: str:
    if cond
    then str
    else "";
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.populate-prowlarr = {
      description = "Populate the Prowlarr database with applications and tags";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "populate_prowlarr.py" {}
          ''
            import os
            import sqlite3

            PROWLARR_DB_PATH = "/var/lib/prowlarr/prowlarr.db"
            HOMEPAGE_ENV = "${config.sops.secrets."home-server/homepage.env".path}"

            APPS = [
                ${optStr cfgMs.books ''("Readarr", "books"),''}
                ${optStr cfgMs.books ''("Speakarr", "books"),''}
                ${optStr cfgMs.music ''("Lidarr", "music"),''}
                ${optStr cfgMs.movies ''("Radarr", "movies"),''}
                ${optStr cfgMs.telly ''("Sonarr", "telly"),''}
            ]

            TAGS = {
                "general": 1,
                "movies": 2,
                "telly": 3,
                "music": 4,
                "books": 5,
            }


            def get_env(var_name: str) -> str:
                with open(HOMEPAGE_ENV) as f:
                    for line in f.read().splitlines():
                        if line == "":
                            continue

                        [name, val] = line.split("=", 1)
                        if name == var_name:
                            return val

                raise RuntimeError(
                    f"Environment variable {var_name} not defined in {HOMEPAGE_ENV}"
                )


            def set_tags() -> None:
                if not os.path.exists(PROWLARR_DB_PATH):
                    raise RuntimeError(f"Database at {PROWLARR_DB_PATH} doesn't exist")

                conn = sqlite3.connect(PROWLARR_DB_PATH)
                cur = conn.cursor()

                cur.execute("DELETE FROM Tags")

                for tag, number in TAGS.items():
                    cur.execute(f"INSERT INTO Tags (Id, Label) VALUES ({number}, '{tag}')")

                conn.commit()


            def add_applications() -> None:
                if not os.path.exists(PROWLARR_DB_PATH):
                    raise RuntimeError(f"Database at {PROWLARR_DB_PATH} doesn't exist")

                conn = sqlite3.connect(PROWLARR_DB_PATH)
                cur = conn.cursor()

                cur.execute("DELETE FROM Applications")

                for app, tag in APPS:
                    api_key = get_env(f"HOMEPAGE_VAR_{app.upper()}_KEY")

                    settings = (
                        "{\n"
                        '"prowlarrUrl": "https://localhost/prowlarr",'
                        f'"baseUrl": "https://localhost/{app.lower()}",'
                        f'"apiKey": "{api_key}"'
                        "}"
                    )

                    if app == "Speakarr":
                        impl = "Readarr"
                    else:
                        impl = app

                    cur.execute(
                        "INSERT INTO Applications (Name, Implementation, Settings, "
                        f"ConfigContract, SyncLevel, Tags) VALUES ('{app}', '{impl}', "
                        f"'{settings}', '{impl}Settings', 2, '[1, {TAGS[tag]}]')"
                    )

                conn.commit()


            def main() -> None:
                set_tags()
                add_applications()


            if __name__ == '__main__':
                main()
          ''}";
      };
    };
  };
}
