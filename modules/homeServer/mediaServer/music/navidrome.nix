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
    setup = {
      impermanence.keepDirs = ["/var/lib/navidrome"];
      backup.paths = [
        "/var/lib/navidrome.db"
        "/var/lib/navidrome.db-shm"
        "/var/lib/navidrome.db-wal"
      ];
    };

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

    sops.secrets = let
      conf = {
        mode = "0440";
        owner = config.systemd.services.navidrome.serviceConfig.User;
        group = config.systemd.services.navidrome.serviceConfig.Group;
      };
    in {
      "home-server/navidrome/spotify/id" = conf;
      "home-server/navidrome/spotify/secret" = conf;
      "home-server/navidrome/lastfm/apikey" = conf;
      "home-server/navidrome/lastfm/secret" = conf;
    };

    systemd.services.navidrome.serviceConfig = {
      BindReadOnlyPaths = [
        config.sops.secrets."home-server/navidrome/spotify/id".path
        config.sops.secrets."home-server/navidrome/spotify/secret".path
        config.sops.secrets."home-server/navidrome/lastfm/apikey".path
        config.sops.secrets."home-server/navidrome/lastfm/secret".path
      ];

      ExecStart = lib.mkForce "${
        pkgs.writeShellScript "start-navidrome.sh"
        ''
          export ND_SPOTIFY_ID="$(cat ${config.sops.secrets."home-server/navidrome/spotify/id".path})"
          export ND_SPOTIFY_SECRET="$(cat ${config.sops.secrets."home-server/navidrome/spotify/secret".path})"
          export ND_LASTFM_APIKEY="$(cat ${config.sops.secrets."home-server/navidrome/lastfm/apikey".path})"
          export ND_LASTFM_SECRET="$(cat ${config.sops.secrets."home-server/navidrome/lastfm/secret".path})"

          ${config.services.navidrome.package}/bin/navidrome --configfile ${(pkgs.formats.json {}).generate "navidrome.json" config.services.navidrome.settings}
        ''
      }";
    };
  };
}
