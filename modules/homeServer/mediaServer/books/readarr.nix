{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.books) {
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/readarr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.readarr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /readarr/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.readarr}";
          extraConfig = "auth_basic off;";
        };
      };

      readarr = {
        enable = true;
        group = "media";
      };
    };

    systemd.services.readarr = {
      after = ["servarr-config.target"];
      requires = ["servarr-config.target"];
    };
  };
}
