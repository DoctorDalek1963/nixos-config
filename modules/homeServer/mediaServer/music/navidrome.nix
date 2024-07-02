{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.music) {
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations."/navidrome" = {
        proxyPass = "http://localhost:${toString cfg.ports.mediaServer.navidrome}";
      };

      navidrome = {
        enable = true;
        group = "media";

        settings = {
          Port = cfg.ports.mediaServer.navidrome;
          MusicFolder = "${cfgMs.mediaRoot}/music";
          BaseUrl = "/navidrome";

          DefaultTheme = "Auto";
          FFmpegPath = "${pkgs.ffmpeg}/bin/ffmpeg";
          ScanSchedule = "@every 15m";
        };
      };
    };
  };
}
