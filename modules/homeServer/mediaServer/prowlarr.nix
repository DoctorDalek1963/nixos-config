{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
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

      # TODO: Add <UrlBase>prowlarr</UrlBase> to ${config.services.prowlarr.dataDir}/config.xml
      # TODO: PR nixpkgs to bring parity with *arr to Prowlarr's options (user, group, dataDir)

      prowlarr = {
        enable = true;
        # group = "media";

        openFirewall = true;
      };
    };
  };
}
