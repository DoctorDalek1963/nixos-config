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
        openFirewall = true;
      };
    };

    systemd.services.readarr = {
      after = ["set-servarr-configs.service"];
      requires = ["set-servarr-configs.service"];
    };

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/books
      chown -R readarr:media ${cfgMs.mediaRoot}/books

      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads/books
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents/downloads/books
    '';
  };
}
