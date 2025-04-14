{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgNc = config.setup.homeServer.nextcloud;
in {
  config = lib.mkIf (cfg.enable && cfgNc.enable) {
    sops.secrets = {
      "home-server/nextcloud/admin-pass" = {
        mode = "0400";
        owner = config.users.users.nextcloud.name;
        inherit (config.users.users.nextcloud) group;
      };
    };

    services = {
      nextcloud = {
        enable = true;
        package = pkgs.nextcloud31;

        datadir = cfgNc.cloudRoot;

        hostName = "nextcloud.${cfg.domainName}";

        extraAppsEnable = true;
        extraApps = {
          inherit (config.services.nextcloud.package.packages.apps) calendar contacts tasks;
        };

        config = {
          adminuser = "admin";
          adminpassFile = config.sops.secrets."home-server/nextcloud/admin-pass".path;
          dbtype = "sqlite";
        };

        database.createLocally = true;
        configureRedis = true;

        https = false;

        settings = {
          overwriteprotocol = "https";
          overwritehost = "${config.services.nextcloud.hostName}:${toString cfg.ports.nextcloud}";
          overwritewebroot = "/nextcloud";
          overwrite.cli.url = "https://${cfg.domainName}/nextcloud/";
          htaccess.RewriteBase = "/nextcloud";

          trusted_domains = [cfg.domainName];
          trusted_proxies = ["127.0.0.1"];

          log_type = "syslog";
          syslog_tag = "Nextcloud";
          loglevel = 1; # TODO: Set this back to 2 once setup properly to avoid excessive logs
        };
      };

      nginx.virtualHosts = {
        "${config.services.nextcloud.hostName}".listen = [
          {
            addr = "127.0.0.1";
            port = cfg.ports.nextcloud;
          }
        ];

        "${cfg.domainName}".locations."/nextcloud/" = {
          proxyPass = "http://127.0.0.1:${toString cfg.ports.nextcloud}/";

          # proxy_pass http://127.0.0.1:8080/; # tailing / is important!
          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-NginX-Proxy true;
            proxy_set_header X-Forwarded-Proto http;
            proxy_set_header Host ${config.services.nextcloud.hostName};
            proxy_cache_bypass $http_upgrade;
            proxy_redirect off;
          '';
        };
      };
    };
  };
}
