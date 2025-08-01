{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  indent4 =
    code:
    builtins.concatStringsSep "\n" (
      builtins.map (line: "    ${line}") (
        builtins.filter (x: builtins.isString x && x != "") (lib.strings.split "\n" code)
      )
    );

  optSnippet = cond: code: if cond then indent4 code else "";

  readarr = optSnippet config.services.readarr.enable ''
    calibre_settings = {
        "host": "localhost",
        "port": ${toString cfg.ports.mediaServer.calibre.server},
        "username": "admin",
        "password": "admin",
        "library": "ebooks",
        "outputFormat": "epub",
        "outputProfile": 0,
        "useSsl": False,
    }

    add_root_folder(
        "${config.services.readarr.dataDir}/readarr.db",
        "INSERT INTO RootFolders (Path, Name, DefaultMetadataProfileId, "
        "DefaultQualityProfileId, DefaultTags, IsCalibreLibrary, "
        "CalibreSettings) VALUES ('${cfgMs.mediaRoot}/ebooks/', "
        f"'Calibre', 1, 1, '[]', 1, '{json.dumps(calibre_settings)}')"
    )
  '';
  speakarr = optSnippet config.services.speakarr.enable ''
    add_root_folder(
        "${config.services.speakarr.dataDir}/speakarr.db",
        "INSERT INTO RootFolders (Path, Name, DefaultMetadataProfileId, "
        "DefaultQualityProfileId, DefaultTags, IsCalibreLibrary) VALUES "
        "('${cfgMs.mediaRoot}/audiobooks/', 'Audiobookshelf', 1, 2, '[]', 0)"
    )
  '';
  lidarr = optSnippet config.services.lidarr.enable ''
    add_root_folder(
        "${config.services.lidarr.dataDir}/lidarr.db",
        "INSERT INTO RootFolders (Path, Name, DefaultMetadataProfileId, "
        "DefaultQualityProfileId, DefaultTags) VALUES "
        "('${cfgMs.mediaRoot}/music/', 'Root', 1, 4, '[]')"
    )
  '';
  radarr = optSnippet config.services.radarr.enable ''
    add_root_folder(
        "${config.services.radarr.dataDir}/radarr.db",
        "INSERT INTO RootFolders (Path) VALUES ('${cfgMs.mediaRoot}/jellyfin/movies/')"
    )
  '';
  sonarr = optSnippet config.services.sonarr.enable ''
    add_root_folder(
        "${config.services.sonarr.dataDir}/sonarr.db",
        "INSERT INTO RootFolders (Path) VALUES ('${cfgMs.mediaRoot}/jellyfin/telly/')"
    )
  '';
  whisparr = optSnippet config.services.whisparr.enable ''
    add_root_folder(
        "${config.services.whisparr.dataDir}/whisparr2.db",
        "INSERT INTO RootFolders (Path) VALUES ('${cfgMs.mediaRoot}/porn/staging/')"
    )
  '';
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.add-servarr-root-folders = {
      description = "Add root folders to all the servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "add_servarr_root_folders.py"
          {
            flakeIgnore = [
              "W293"
              "E303"
              "E501"
            ];
          }
          ''
            import json
            import os
            import sqlite3


            def add_root_folder(
                db_path: str, insert_command: str, *, delete_root_folders: bool = True
            ) -> None:
                if not os.path.exists(db_path):
                    raise RuntimeError(f"Database at {db_path} doesn't exist")

                conn = sqlite3.connect(db_path)
                cur = conn.cursor()

                if delete_root_folders:
                    cur.execute("DELETE FROM RootFolders")
                elif len(cur.execute("SELECT * FROM RootFolders").fetchmany()) > 0:
                    return

                cur.execute(insert_command)
                conn.commit()


            def main() -> None:
            ${readarr}
            ${speakarr}
            ${lidarr}
            ${radarr}
            ${sonarr}
            ${whisparr}


            if __name__ == '__main__':
                main()
          ''
        }";
      };
    };
  };
}
