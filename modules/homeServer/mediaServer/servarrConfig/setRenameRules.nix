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
    set_naming_config(
        "${config.services.readarr.dataDir}/readarr.db",
        "INSERT INTO NamingConfig (ReplaceIllegalCharacters, "
        "AuthorFolderFormat, RenameBooks, StandardBookFormat, "
        "ColonReplacementFormat) VALUES (1, '{Author Name}', 1, "
        "'{Book Title}{ (Part PartNumber)}', 4)"
    )
  '';
  speakarr = optSnippet config.services.speakarr.enable ''
    set_naming_config(
        "${config.services.speakarr.dataDir}/speakarr.db",
        "INSERT INTO NamingConfig (ReplaceIllegalCharacters, "
        "AuthorFolderFormat, RenameBooks, StandardBookFormat, "
        "ColonReplacementFormat) VALUES (1, '{Author Name}', 1, "
        "'{Book Title}/{Part PartNumber}', 4)"
    )
  '';
  lidarr = optSnippet config.services.lidarr.enable ''
    set_naming_config(
        "${config.services.lidarr.dataDir}/lidarr.db",
        "INSERT INTO NamingConfig (ReplaceIllegalCharacters, "
        "ArtistFolderFormat, RenameTracks, StandardTrackFormat, "
        "MultiDiscTrackFormat, ColonReplacementFormat) VALUES (1, "
        "'{Artist Name}', 1, '{Album Title} ({Release Year})/{Artist Name} "
        "- {Album Title} - {track:00} - {Track Title}', '{Album Title} "
        "({Release Year})/Disk {medium:00} - {Artist Name} - {Album Title} "
        "- {track:00} - {Track Title}', 4)"
    )
  '';
  radarr = optSnippet config.services.radarr.enable ''
    set_naming_config(
        "${config.services.radarr.dataDir}/radarr.db",
        "INSERT INTO NamingConfig (ReplaceIllegalCharacters, "
        "StandardMovieFormat, MovieFolderFormat,"
        "ColonReplacementFormat, RenameMovies) VALUES (1, '{Movie Title} "
        "({Release Year}) - {Quality Full}', '{Movie Title} ({Release Year})'"
        ", 4, 1);"
    )
  '';
  sonarr = optSnippet config.services.sonarr.enable ''
    set_naming_config(
        "${config.services.sonarr.dataDir}/sonarr.db",
        "INSERT INTO NamingConfig (MultiEpisodeStyle, RenameEpisodes, "
        "StandardEpisodeFormat, DailyEpisodeFormat, SeasonFolderFormat, "
        "SeriesFolderFormat, AnimeEpisodeFormat, ReplaceIllegalCharacters, "
        "SpecialsFolderFormat, ColonReplacementFormat) VALUES"
        "(4, 1, '{Series Title} - S{season:00}E{episode:00} - {Episode Title} "
        "- {Quality Full}', '{Series Title} - {Air-Date} - {Episode Title} "
        "- {Quality Full}', 'Season {season}', '{Series Title}', "
        "'{Series Title} - S{season:00}E{episode:00} - {Episode Title} "
        "- {Quality Full}', 1, 'Specials', 4)"
    )
  '';
  whisparr = optSnippet config.services.whisparr.enable ''
    set_naming_config(
        "${config.services.whisparr.dataDir}/whisparr2.db",
        "INSERT INTO NamingConfig (MultiEpisodeStyle, RenameEpisodes, "
        "SeriesFolderFormat, StandardEpisodeFormat, ReplaceIllegalCharacters, "
        "ColonReplacementFormat) VALUES (4, 1, '{Site Title}', "
        "'{Site Title} - {Episode Title} - {Episode Performers} - "
        "{Release-Date}', 1, 4)"
    )
  '';
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.set-servarr-rename-rules = {
      description = "Set the renaming rules for all the servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${pkgs.writers.writePython3 "set_servarr_rename_rules.py"
          {
            flakeIgnore = [
              "W293"
              "E303"
            ];
          }
          ''
            import os
            import sqlite3


            def set_naming_config(db_path: str, insert_command: str) -> None:
                if not os.path.exists(db_path):
                    raise RuntimeError(f"Database at {db_path} doesn't exist")

                conn = sqlite3.connect(db_path)
                cur = conn.cursor()

                cur.execute("DELETE FROM NamingConfig")
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
