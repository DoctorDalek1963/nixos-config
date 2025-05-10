{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.telly) {
    setup = {
      impermanence.keepDirs = [config.services.sonarr.dataDir];
      backup.exclude = ["${cfgMs.mediaRoot}/jellyfin/telly"];

      homeServer.mediaServer.directoryMap = {
        jellyfin = ["${cfgMs.mediaRoot}/jellyfin/telly"];
        transmission = ["${cfgMs.mediaRoot}/torrents/downloads/telly"];
      };
    };

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/sonarr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.sonarr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /sonarr/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.sonarr}";
          extraConfig = "auth_basic off;";
        };
      };

      sonarr = {
        enable = true;
        group = "media";

        settings = {
          app.instancename = "Sonarr";
          server = {
            port = cfg.ports.mediaServer.sonarr;
            urlbase = "sonarr";
          };
          auth = {
            required = "Enabled";
            method = "Basic";
          };
        };
      };
    };

    systemd.services.sonarr = {
      after = ["servarr-config.service"];
      requires = ["servarr-config.service"];
    };
  };
}
