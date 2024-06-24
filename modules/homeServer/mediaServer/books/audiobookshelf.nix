{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.books) {
    services.audiobookshelf = {
      enable = true;
      group = "media";
      port = cfg.ports.mediaServer.audiobookshelf;
    };
  };
}
