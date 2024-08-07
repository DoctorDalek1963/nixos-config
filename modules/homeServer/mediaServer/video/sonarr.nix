{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.telly) {
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

    systemd.services.sonarr = {
      after = ["servarr-config.service"];
      requires = ["servarr-config.service"];
    };

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/telly
      chown -R jellyfin:media ${cfgMs.mediaRoot}/telly

      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads/telly
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents/downloads/telly
    '';
  };
}
