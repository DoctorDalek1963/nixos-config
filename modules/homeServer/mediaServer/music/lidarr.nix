{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.music) {
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

    systemd.services.lidarr = {
      after = ["servarr-config.target"];
      requires = ["servarr-config.target"];
    };

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/music
      chown -R lidarr:media ${cfgMs.mediaRoot}/music

      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads/music
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents/downloads/music
    '';
  };
}
