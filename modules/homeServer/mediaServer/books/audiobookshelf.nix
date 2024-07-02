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

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/audiobooks
      chown -R audiobookshelf:media ${cfgMs.mediaRoot}/audiobooks
    '';
  };
}
