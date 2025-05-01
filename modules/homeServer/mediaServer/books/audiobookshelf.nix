{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.books) {
    setup = {
      impermanence.keepDirs = ["/var/lib/audiobookshelf"];
      backup.paths = [
        "/var/lib/audiobookshelf/config/absdatabase.sqlite"
        "/var/lib/audiobookshelf/metadata"
      ];
    };

    services.audiobookshelf = {
      enable = true;
      group = "media";
      port = cfg.ports.mediaServer.audiobookshelf;
    };

    systemd.tmpfiles.settings.books."${cfgMs.mediaRoot}/audiobookshelf".d = {
      user = "audiobookshelf";
      group = "media";
      mode = "775";
    };
  };
}
