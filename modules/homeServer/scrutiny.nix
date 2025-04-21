{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf cfg.scrutiny.enable {
    setup.impermanence.keepDirs = [
      {
        directory = "/var/lib/private/scrutiny";
        user = "scrutiny";
        group = "scrutiny";
        mode = "0750";
      }
      {
        directory = "/var/lib/influxdb2";
        user = "influxdb2";
        group = "influxdb2";
        mode = "0755";
      }
    ];

    services = {
      scrutiny = {
        enable = true;

        influxdb.enable = true;

        settings = {
          web.listen = {
            port = cfg.ports.scrutiny;
            basepath = "/scrutiny";
          };
        };

        # For some reason, using the default localhost:port API endpoint
        # doesn't work (yes it defaults to the correct port). That method
        # returns HTML, which the collector can't parse. If we use the public
        # TLS URL then we get a JSON response, which is fine.
        collector.settings.api.endpoint = "https://${cfg.domainName}/scrutiny";
      };

      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/scrutiny" = {
          proxyPass = "http://localhost:${toString cfg.ports.scrutiny}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };
      };
    };
  };
}
