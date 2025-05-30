{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    setup.impermanence.keepDirs = [config.services.prowlarr.dataDir];

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/prowlarr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.prowlarr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /prowlarr(/[0-9]+)?/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.prowlarr}";
          extraConfig = "auth_basic off;";
        };
      };

      prowlarr = {
        enable = true;

        settings = {
          app.instancename = "Prowlarr";
          server = {
            port = cfg.ports.mediaServer.prowlarr;
            urlbase = "prowlarr";
          };
          auth = {
            required = "Enabled";
            method = "Basic";
          };
        };
      };
    };

    systemd.services.prowlarr = {
      after = ["servarr-config.service"];
      requires = ["servarr-config.service"];

      serviceConfig = {
        DynamicUser = lib.mkForce false;
        User = "prowlarr";
        Group = "media";
      };
    };
  };
}
