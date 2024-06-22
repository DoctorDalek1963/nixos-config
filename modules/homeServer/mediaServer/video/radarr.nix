{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.movies) {
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
      };
    };

    systemd.services.radarr = {
      after = ["servarr-config.target"];
      requires = ["servarr-config.target"];
    };

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/movies
      chown -R jellyfin:media ${cfgMs.mediaRoot}/movies

      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads/movies
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents/downloads/movies
    '';
  };
}
