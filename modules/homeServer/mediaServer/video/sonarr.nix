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
      backup.exclude = ["${cfgMs.mediaRoot}/telly"];
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
      };
    };

    systemd = {
      services.sonarr = {
        after = ["servarr-config.service"];
        requires = ["servarr-config.service"];
      };

      tmpfiles.rules = [
        "d ${cfgMs.mediaRoot}/telly 0775 jellyfin media - -"
        "d ${cfgMs.mediaRoot}/torrents/downloads/telly 0775 transmission media - -"
      ];
    };
  };
}
