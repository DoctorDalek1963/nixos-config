{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/jellyfin" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.jellyfin.http}";
          extraConfig = ''
            proxy_pass_request_headers on;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
            proxy_buffering off;
          '';
        };
      };

      jellyfin = {
        enable = true;
        user = "jellyfin";
        group = "media";
      };
    };
  };
}
