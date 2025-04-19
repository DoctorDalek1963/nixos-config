{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    # TODO: Next time I enable this, add setup.backup.paths for databases etc.
    setup.impermanence.keepDirs = ["/var/lib/private/jellyseerr"];

    services.jellyseerr = {
      enable = true;
      # group = "media";
      port = cfg.ports.mediaServer.jellyseerr;
    };
  };
}
