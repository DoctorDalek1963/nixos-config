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
      firefly-iii = {
        enable = true;

        package = pkgs.firefly-iii.overrideAttrs (oldAttrs: {
          nativeBuildInputs = oldAttrs.nativeBuildInputs ++ [pkgs.fd pkgs.sd];

          preBuild = ''
            fd . -e twig . -X sd -F "route('index')" "route('home')"
          '';
        });

        inherit (config.services.nginx) group;

        poolConfig =
          options.services.firefly-iii.poolConfig.default
          // {
            "listen.mode" = "0666";
            "access.log" = "${config.services.firefly-iii.dataDir}/access.log";
          };

        settings = {
          APP_KEY_FILE = config.sops.secrets."home-server/firefly-iii/key-file".path;
          APP_URL = "https://${cfg.domainName}/firefly-iii";

          TRUSTED_PROXIES = "**";

          # Make sure "${config.services.firefly-iii.dataDir}/storage/database/database.sqlite" exists
          DB_CONNECTION = "sqlite";
        };
      };

      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/firefly-iii/" = {
          alias = "${config.services.firefly-iii.package}/public/";
          index = "index.php";
          tryFiles = "$uri $uri/ @firefly-iii";

          extraConfig = ''
            sendfile off;

            location ~* \.php(?:$|/) {
               include ${config.services.nginx.package}/conf/fastcgi_params;
               fastcgi_pass unix:${config.services.phpfpm.pools.firefly-iii.socket};
               fastcgi_param SCRIPT_FILENAME $request_filename;
               fastcgi_param HTTP_PROXY "";
               fastcgi_param modHeadersAvailable true;
            }
          '';
        };

        "/firefly-iii".return = "301 /firefly-iii/home";

        "@firefly-iii" = {
          extraConfig = "rewrite ^/firefly-iii/(.*)$ /firefly-iii/index.php?/$1 last;";
        };
      };
    };
  };
}
