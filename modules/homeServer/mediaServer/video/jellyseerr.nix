{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    services.jellyseerr = {
      enable = true;
      # group = "media";
      port = cfg.ports.mediaServer.jellyseerr;
    };
  };
}
