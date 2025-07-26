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
    ITEMS = [
        {"quality": 0, "items": [], "allowed": False},
        {"quality": 1, "items": [], "allowed": True},
        {"quality": 2, "items": [], "allowed": True},
        {"quality": 3, "items": [], "allowed": True},
        {"quality": 4, "items": [], "allowed": True},
        {"quality": 13, "items": [], "allowed": False},
        {"quality": 10, "items": [], "allowed": False},
        {"quality": 12, "items": [], "allowed": False},
        {"quality": 11, "items": [], "allowed": False},
    ]

    set_quality_profile(
        "${config.services.readarr.dataDir}/readarr.db",
        "INSERT INTO QualityProfiles (Id, Name, Cutoff, Items, "
        "UpgradeAllowed, FormatItems, MinFormatScore, CutoffFormatScore) "
        f"VALUES (1, 'eBook', 2, '{json.dumps(ITEMS)}', 0, '[]', 0, 0)",
    )
  '';
  speakarr = optSnippet config.services.speakarr.enable ''
    ITEMS = [
        {"quality": 0, "items": [], "allowed": False},
        {"quality": 1, "items": [], "allowed": False},
        {"quality": 2, "items": [], "allowed": False},
        {"quality": 3, "items": [], "allowed": False},
        {"quality": 4, "items": [], "allowed": False},
        {"quality": 13, "items": [], "allowed": True},
        {"quality": 10, "items": [], "allowed": True},
        {"quality": 12, "items": [], "allowed": True},
        {"quality": 11, "items": [], "allowed": True},
    ]

    set_quality_profile(
        "${config.services.speakarr.dataDir}/speakarr.db",
        "INSERT INTO QualityProfiles (Id, Name, Cutoff, Items, "
        "UpgradeAllowed, FormatItems, MinFormatScore, CutoffFormatScore) "
        f"VALUES (2, 'Audiobook', 10, '{json.dumps(ITEMS)}', 0, '[]', 0, 0)",
    )
  '';

  lidarr = optSnippet config.services.lidarr.enable ''
    LOSSLESS_ITEMS = [
        {
            "id": 1005,
            "name": "Lossless",
            "items": [
                {"quality": 6, "items": [], "allowed": True},
                {"quality": 7, "items": [], "allowed": True},
                {"quality": 35, "items": [], "allowed": True},
                {"quality": 36, "items": [], "allowed": True},
                {"quality": 21, "items": [], "allowed": True},
                {"quality": 37, "items": [], "allowed": True},
            ],
            "allowed": True,
        },
    ]

    STANDARD_ITEMS = [
        {
            "id": 1002,
            "name": "Low Quality Lossy",
            "items": [
                {"quality": 1, "items": [], "allowed": True},
                {"quality": 18, "items": [], "allowed": True},
                {"quality": 9, "items": [], "allowed": True},
                {"quality": 20, "items": [], "allowed": True},
                {"quality": 34, "items": [], "allowed": True},
            ],
            "allowed": True,
        },
        {
            "id": 1003,
            "name": "Mid Quality Lossy",
            "items": [
                {"quality": 17, "items": [], "allowed": True},
                {"quality": 8, "items": [], "allowed": True},
                {"quality": 3, "items": [], "allowed": True},
                {"quality": 16, "items": [], "allowed": True},
                {"quality": 10, "items": [], "allowed": True},
            ],
            "allowed": True,
        },
        {
            "id": 1004,
            "name": "High Quality Lossy",
            "items": [
                {"quality": 2, "items": [], "allowed": True},
                {"quality": 12, "items": [], "allowed": True},
                {"quality": 4, "items": [], "allowed": True},
                {"quality": 15, "items": [], "allowed": True},
                {"quality": 11, "items": [], "allowed": True},
                {"quality": 14, "items": [], "allowed": True},
            ],
            "allowed": True,
        },
    ]

    PREFER_GOOD_LOSSY_ITEMS = [
        {
            "id": 1005,
            "name": "Lossless",
            "items": [
                {"quality": 6, "items": [], "allowed": True},
                {"quality": 7, "items": [], "allowed": True},
                {"quality": 35, "items": [], "allowed": True},
                {"quality": 36, "items": [], "allowed": True},
                {"quality": 21, "items": [], "allowed": True},
                {"quality": 37, "items": [], "allowed": True},
            ],
            "allowed": True,
        },
        {
            "id": 1003,
            "name": "Mid Quality Lossy",
            "items": [
                {"quality": 17, "items": [], "allowed": True},
                {"quality": 8, "items": [], "allowed": True},
                {"quality": 3, "items": [], "allowed": True},
                {"quality": 16, "items": [], "allowed": True},
                {"quality": 10, "items": [], "allowed": True},
            ],
            "allowed": True,
        },
        {
            "id": 1004,
            "name": "High Quality Lossy",
            "items": [
                {"quality": 2, "items": [], "allowed": True},
                {"quality": 12, "items": [], "allowed": True},
                {"quality": 4, "items": [], "allowed": True},
                {"quality": 15, "items": [], "allowed": True},
                {"quality": 11, "items": [], "allowed": True},
                {"quality": 14, "items": [], "allowed": True},
            ],
            "allowed": True,
        },
    ]

    set_quality_profile(
        "${config.services.lidarr.dataDir}/lidarr.db",
        "INSERT INTO QualityProfiles (Id, Name, Cutoff, Items, UpgradeAllowed, "
        "FormatItems, MinFormatScore, CutoffFormatScore) VALUES "
        f"(2, 'Lossless', 1005, '{json.dumps(LOSSLESS_ITEMS)}', 0, '[]', 0, 0), "
        f"(3, 'Standard', 1002, '{json.dumps(STANDARD_ITEMS)}', 0, '[]', 0, 0), "
        f"(4, 'Prefer Good Lossy', 1004, '{json.dumps(PREFER_GOOD_LOSSY_ITEMS)}', 1, '[]', 0, 0)",
    )
  '';
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.set-servarr-quality-profiles = {
      description = "Set the quality profiles for servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "set_servarr_quality_profiles.py"
          { flakeIgnore = [ "E501" ]; }
          ''
            import json
            import os
            import sqlite3


            def set_quality_profile(db_path: str, insert_command: str) -> None:
                if not os.path.exists(db_path):
                    raise RuntimeError(f"Database at {db_path} doesn't exist")

                conn = sqlite3.connect(db_path)
                cur = conn.cursor()

                cur.execute("DELETE FROM QualityProfiles")
                cur.execute(insert_command)
                conn.commit()


            def main() -> None:
            ${readarr}
            ${speakarr}
            ${lidarr}


            if __name__ == '__main__':
                main()
          ''
        }";
      };
    };
  };
}
