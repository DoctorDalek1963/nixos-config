{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.music) {
    setup.impermanence.keepDirs = [config.services.lidarr.dataDir];

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/lidarr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.lidarr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /lidarr/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.lidarr}";
          extraConfig = "auth_basic off;";
        };
      };

      lidarr = {
        enable = true;
        group = "media";
      };
    };

    systemd = {
      services.lidarr = {
        after = ["servarr-config.service"];
        requires = ["servarr-config.service"];
      };

      tmpfiles.rules = [
        "d ${cfgMs.mediaRoot}/music 0775 lidarr media - -"
        "d ${cfgMs.mediaRoot}/torrents/downloads/music 0775 transmission media - -"
      ];
    };
  };
}
