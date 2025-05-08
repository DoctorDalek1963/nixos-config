{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.porn) {
    setup = {
      impermanence.keepDirs = [config.services.stash.dataDir];

      backup = {
        paths = []; # TODO: Which paths need backing up?
        exclude = [config.services.stash.settings.cache];
      };

      homeServer.mediaServer.directoryMap.stash = [
        "${cfgMs.mediaRoot}/porn"
        "${cfgMs.mediaRoot}/porn/videos"
        "${cfgMs.mediaRoot}/porn/images"
      ];
    };

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/stash" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.stash}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };
      };

      stash = {
        enable = true;
        group = "media";

        settings = {
          stash = [
            {
              path = "${cfgMs.mediaRoot}/porn/videos";
              excludeimage = true;
            }
            {
              path = "${cfgMs.mediaRoot}/porn/images";
              excludevideo = true;
            }
          ];

          port = cfg.ports.mediaServer.stash;
        };
      };
    };
  };
}
