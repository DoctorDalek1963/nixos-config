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

    sops.secrets = {
      "home-server/navidrome/spotify/id".mode = "0400";
      "home-server/navidrome/spotify/secret".mode = "0400";
      "home-server/navidrome/lastfm/apikey".mode = "0400";
      "home-server/navidrome/lastfm/secret".mode = "0400";
    };

    systemd.services.navidrome.serviceConfig.ExecStart = lib.mkForce "${
      pkgs.writeShellScript "start-navidrome.sh"
      ''
        ND_SPOTIFY_ID="$(cat ${config.sops.secrets."home-server/navidrome/spotify/id".path})"
        ND_SPOTIFY_SECRET="$(cat ${config.sops.secrets."home-server/navidrome/spotify/secret".path})"
        ND_LASTFM_APIKEY="$(cat ${config.sops.secrets."home-server/navidrome/lastfm/apikey".path})"
        ND_LASTFM_SECRET="$(cat ${config.sops.secrets."home-server/navidrome/lastfm/secret".path})"

        ${config.services.navidrome.package}/bin/navidrome --configfile ${(pkgs.formats.json {}).generate "navidrome.json" config.services.navidrome.settings}
      ''
    }";
  };
}
