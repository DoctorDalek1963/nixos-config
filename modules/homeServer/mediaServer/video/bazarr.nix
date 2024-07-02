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
        "/bazarr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.bazarr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /bazarr/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.bazarr}";
          extraConfig = "auth_basic off;";
        };
      };

      bazarr = {
        enable = true;
        group = "media";
        # dataDir = "/var/lib/bazarr";
        listenPort = cfg.ports.mediaServer.bazarr;
      };
    };

    systemd.services.bazarr = {
      after = ["servarr-config.service"];
      requires = ["servarr-config.service"];
    };

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/subtitles
      chown -R bazarr:media ${cfgMs.mediaRoot}/subtitles
    '';
  };
}
