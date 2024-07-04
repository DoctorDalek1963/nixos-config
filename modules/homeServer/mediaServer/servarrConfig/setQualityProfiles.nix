{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  indent4 = code:
    builtins.concatStringsSep "\n"
    (
      builtins.map (line: "    ${line}")
      (
        builtins.filter
        (x: builtins.isString x && x != "")
        (lib.strings.split "\n" code)
      )
    );

  optSnippet = cond: code:
    if cond
    then indent4 code
    else "";

  readarr = optSnippet cfgMs.books ''
    ITEMS = [
        {"quality": 0, "items": [], "allowed": False},
        {"quality": 1, "items": [], "allowed": True},
        {"quality": 2, "items": [], "allowed": True},
        {"quality": 3, "items": [], "allowed": True},
        {"quality": 4, "items": [], "allowed": True},
        {"quality": 10, "items": [], "allowed": False},
        {"quality": 11, "items": [], "allowed": False},
        {"quality": 12, "items": [], "allowed": False},
        {"quality": 13, "items": [], "allowed": False},
    ]

    set_quality_profile(
        "${config.services.readarr.dataDir}/readarr.db",
        "INSERT INTO QualityProfiles (Id, Name, Cutoff, Items, "
        "UpgradeAllowed, FormatItems, MinFormatScore, CutoffFormatScore) "
        f"VALUES (1, 'eBook', 2, '{json.dumps(ITEMS)}', 0, '[]', 0, 0)",
    )
  '';
  speakarr = optSnippet cfgMs.books ''
    ITEMS = [
        {"quality": 0, "items": [], "allowed": False},
        {"quality": 1, "items": [], "allowed": False},
        {"quality": 2, "items": [], "allowed": False},
        {"quality": 3, "items": [], "allowed": False},
        {"quality": 4, "items": [], "allowed": False},
        {"quality": 10, "items": [], "allowed": True},
        {"quality": 11, "items": [], "allowed": True},
        {"quality": 12, "items": [], "allowed": True},
        {"quality": 13, "items": [], "allowed": True},
    ]

    set_quality_profile(
        "${config.services.speakarr.dataDir}/speakarr.db",
        "INSERT INTO QualityProfiles (Id, Name, Cutoff, Items, "
        "UpgradeAllowed, FormatItems, MinFormatScore, CutoffFormatScore) "
        f"VALUES (2, 'Audiobook', 10, '{json.dumps(ITEMS)}', 0, '[]', 0, 0)",
    )
  '';
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.set-servarr-quality-profiles = {
      description = "Set the quality profiles for servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "set_servarr_quality_profiles.py" {}
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


            if __name__ == '__main__':
                main()
          ''}";
      };
    };
  };
}
