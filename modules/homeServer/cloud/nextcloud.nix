{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgNc = config.setup.homeServer.cloud.nextcloud;
in {
  config = lib.mkIf (cfg.enable && cfgNc.enable) {
    setup = {
      impermanence.keepDirs = [
        config.services.nextcloud.home
        "/var/lib/redis-nextcloud"
      ];
      backup.paths = [config.services.nextcloud.datadir];
    };

    sops.secrets = {
      "home-server/nextcloud/admin-pass" = {
        mode = "0400";
        owner = config.users.users.nextcloud.name;
        inherit (config.users.users.nextcloud) group;
      };
    };

    users.groups.nextcloud = {
      members = lib.optional (cfg.manager != null) cfg.manager;
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
          overwritehost = cfg.domainName;
          overwritewebroot = "/nextcloud";
          overwrite.cli.url = "https://${cfg.domainName}/nextcloud/";
          htaccess.RewriteBase = "/nextcloud";

          trusted_domains = [cfg.domainName];
          trusted_proxies = ["127.0.0.1"];

          log_type = "syslog";
          syslog_tag = "Nextcloud";
          loglevel = 2;
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

          recommendedProxySettings = false;

          extraConfig = ''
            proxy_set_header X-Real-IP $remote_addr;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header X-NginX-Proxy true;
            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Server ${config.services.nextcloud.hostName};
            proxy_set_header Host ${config.services.nextcloud.hostName};

            proxy_cache_bypass $http_upgrade;
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
