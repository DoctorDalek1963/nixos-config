{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    setup = {
      impermanence.keepDirs = [
        config.services.jellyfin.dataDir
        config.services.jellyfin.cacheDir
      ];

      backup = {
        paths = [config.services.jellyfin.dataDir];
        exclude = ["${config.services.jellyfin.dataDir}/log"];
      };

      homeServer.mediaServer.directoryMap.jellyfin = [
        "${cfgMs.mediaRoot}/jellyfin"
      ];
    };

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
