{
  pkgs,
  lib,
  config,
  options,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf (cfg.enable && cfg.firefly-iii.enable) {
    sops.secrets = {
      "home-server/firefly-iii/key-file" = {
        mode = "0400";
        owner = config.services.firefly-iii.user;
        inherit (config.services.firefly-iii) group;
      };
    };

    services = {
      phpfpm.settings.log_level = "debug";

      firefly-iii = {
        enable = true;

        inherit (config.services.nginx) group;

        poolConfig =
          options.services.firefly-iii.poolConfig.default
          // {
            "listen.mode" = "0666";
            "access.log" = "${config.services.firefly-iii.dataDir}/access.log";
          };

        settings = {
          APP_DEBUG = true;
          APP_LOG_LEVEL = "debug";

          APP_KEY_FILE = config.sops.secrets."home-server/firefly-iii/key-file".path;
          # APP_URL = "https://${cfg.domainName}:${toString cfg.ports.haproxy.firefly-iii}";
          APP_URL = "https://${cfg.domainName}/firefly-iii";

          TRUSTED_PROXIES = "**";

          DB_CONNECTION = "mysql";
          DB_PORT = config.services.mysql.replication.masterPort;
          DB_DATABASE = "firefly";
          DB_USERNAME = config.services.firefly-iii.user;
          DB_PASSWORD = "";
        };
      };

      mysql = {
        enable = true;
        package = pkgs.mysql;

        ensureDatabases = [config.services.firefly-iii.settings.DB_DATABASE];
        ensureUsers = [
          {
            name = config.services.firefly-iii.settings.DB_USERNAME;
            ensurePermissions = {
              "${config.services.firefly-iii.settings.DB_DATABASE}.*" = "ALL PRIVILEGES";
            };
          }
        ];
      };

      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/firefly-iii/" = {
          alias = "${config.services.firefly-iii.package}/public";
          index = "index.php";
          tryFiles = "$uri @firefly-iii";
          # tryFiles = "$uri $uri/ /firefly-iii/index.php?$query_string";

          extraConfig = ''
            sendfile off;

            proxy_set_header X-Forwarded-Proto $scheme;
            proxy_set_header X-Forwarded-Host $host;
            proxy_set_header X-Forwarded-Server $host;
            proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
            proxy_set_header Host $host;

            # This line is optional and may help in some cases.
            # proxy_set_header X-Forwarded-Port $server_port;

            client_max_body_size 64M;
            proxy_read_timeout 300s;

            location ~* \.php(?:$|/) {
               fastcgi_pass unix:${config.services.phpfpm.pools.firefly-iii.socket};
               fastcgi_index index.php;
               include ${config.services.nginx.package}/conf/fastcgi_params;
               fastcgi_param SCRIPT_FILENAME $request_filename;
               # fastcgi_param SCRIPT_FILENAME ${config.services.firefly-iii.package}/public/$fastcgi_script_name;
               fastcgi_param HTTP_PROXY "";
               fastcgi_param modHeadersAvailable true;
            }
          '';
        };

        "@firefly-iii" = {
          extraConfig = "rewrite ^/firefly-iii/(.*)$ /firefly-iii/index.php/$1 last;";
        };
      };
    };
  };
}
