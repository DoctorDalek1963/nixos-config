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
      impermanence.keepDirs = ["/var/lib/private/jellyseerr"];
      backup = {
        paths = ["/var/lib/private/jellyseerr"];
        exclude = ["/var/lib/private/jellyseerr/logs"];
      };
    };

    services.jellyseerr = {
      enable = true;
      # group = "media";
      port = cfg.ports.mediaServer.jellyseerr;
    };
  };
}
