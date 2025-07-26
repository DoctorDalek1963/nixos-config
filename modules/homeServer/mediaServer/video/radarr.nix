{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.movies) {
    setup = {
      impermanence.keepDirs = [ config.services.radarr.dataDir ];
      backup.exclude = [ "${cfgMs.mediaRoot}/jellyfin/movies" ];

      homeServer.mediaServer.directoryMap = {
        jellyfin = [ "${cfgMs.mediaRoot}/jellyfin/movies" ];
        transmission = [ "${cfgMs.mediaRoot}/torrents/downloads/movies" ];
      };
    };

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/radarr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.radarr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /radarr/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.radarr}";
          extraConfig = "auth_basic off;";
        };
      };

      radarr = {
        enable = true;
        group = "media";

        settings = {
          app.instancename = "Radarr";
          server = {
            port = cfg.ports.mediaServer.radarr;
            urlbase = "radarr";
          };
          auth = {
            required = "Enabled";
            method = "Basic";
          };
        };
      };
    };

    systemd.services.radarr = {
      after = [ "servarr-config.service" ];
      requires = [ "servarr-config.service" ];
    };
  };
}
