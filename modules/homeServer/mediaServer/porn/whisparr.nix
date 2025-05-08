{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.porn) {
    # TODO: Add Whisparr database setup stuff to servarr-config.service

    setup = {
      impermanence.keepDirs = [config.services.whisparr.dataDir];

      homeServer.mediaServer.directoryMap.transmission = [
        "${cfgMs.mediaRoot}/torrents/downloads/porn"
      ];
    };

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/whisparr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.whisparr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /whisparr/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.whisparr}";
          extraConfig = "auth_basic off;";
        };
      };

      whisparr = {
        enable = true;
        group = "media";

        settings = {
          app.instancename = "Whisparr";
          server = {
            port = cfg.ports.mediaServer.whisparr;
            urlbase = "whisparr";
          };
          auth = {
            required = "Enabled";
            method = "Basic";
          };
        };
      };
    };

    systemd.services.whisparr = {
      after = ["servarr-config.service"];
      requires = ["servarr-config.service"];
    };
  };
}
