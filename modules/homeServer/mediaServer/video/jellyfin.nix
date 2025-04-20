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
    setup.impermanence.keepDirs = [
      config.services.jellyfin.dataDir
      config.services.jellyfin.cacheDir
    ];

    # NOTE: On a fresh install, you first need to connect to
    # http://{ip_address}:8096 and add libraries, then enable HTTPS and set the
    # certificate path to combined.p12
    services.jellyfin = {
      enable = true;
      user = "jellyfin";
      group = "media";
    };

    users.users.jellyfin.extraGroups = ["certs"];
  };
}
