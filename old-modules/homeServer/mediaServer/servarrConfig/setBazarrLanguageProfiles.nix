{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
in
{
  config = lib.mkIf (cfg.enable && cfg.mediaServer.enable) {
    systemd.services.set-bazarr-language-profiles = {
      description = "Set the renaming rules for all the servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "set_bazarr_language_profiles.py"
          {
            flakeIgnore = [
              "W503"
              "E501"
            ];
          }
          ''
            import os
            import sqlite3


            def main() -> None:
                db_path = "/var/lib/bazarr/db/bazarr.db"
                if not os.path.exists(db_path):
                    raise RuntimeError(f"Database at {db_path} doesn't exist")

                conn = sqlite3.connect(db_path)
                cur = conn.cursor()

                if (
                    len(
                        cur.execute(
                            "SELECT * FROM table_languages_profiles WHERE name == 'English'"
                        ).fetchmany()
                    )
                    > 0
                ):
                    return

                cur.execute(
                    "INSERT INTO table_languages_profiles (originalFormat, items, name, "
                    """mustContain, mustNotContain) VALUES (0, '[{"id": 1, "language":"""
                    """ "en", "audio_exclude": "False", "hi": "False", "forced": "False"}"""
                    "]', 'English', '[]', '[]')"
                )
                conn.commit()


            if __name__ == '__main__':
                main()
          ''
        }";
      };
    };
  };
}
