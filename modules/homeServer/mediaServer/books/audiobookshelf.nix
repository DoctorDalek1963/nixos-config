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
      backup.paths = ["/var/lib/audiobookshelf/config/absdatabase.sqlite"];
    };

    services.audiobookshelf = {
      enable = true;
      group = "media";
      port = cfg.ports.mediaServer.audiobookshelf;
    };

    systemd.tmpfiles.rules = ["d ${cfgMs.mediaRoot}/audiobookshelf 0775 audiobookshelf media - -"];
  };
}
