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

    sops.secrets = let
      perms = {
        owner = "stash";
        group = "media";
        mode = "0400";
      };
    in {
      "home-server/stash/password" = perms;
      "home-server/stash/jwt-secret" = perms;
      "home-server/stash/session-store-secret" = perms;
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
            proxy_set_header X-Forwarded-Prefix /stash;

            rewrite ^/stash/(.*)$ /$1 break;
          '';
        };
      };

      stash = {
        enable = true;
        group = "media";

        username = "dyson";
        passwordFile = config.sops.secrets."home-server/stash/password".path;
        jwtSecretKeyFile = config.sops.secrets."home-server/stash/jwt-secret".path;
        sessionStoreKeyFile = config.sops.secrets."home-server/stash/session-store-secret".path;

        # TODO: Remove these and declare plugins and scrapers once I've decided what I want
        mutablePlugins = true;
        mutableScrapers = true;

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

          # This *should* be the default, but it seems like it won't build
          # using the default settings because they use some fancy `apply`
          # option to work with a function, but that causes the generation of
          # config.yml to fail, which causes the whole system build to fail.
          # Looks like https://github.com/NixOS/nixpkgs/pull/402574 should fix
          # this and issue with empty plugin/scraper lists
          ui.frontPageContent = let
            recentlyReleased = mode: {
              __typename = "CustomFilter";
              message = {
                id = "recently_released_objects";
                values.objects = mode;
              };
              mode = lib.toUpper mode;
              sortBy = "date";
              direction = "DESC";
            };
            recentlyAdded = mode: {
              __typename = "CustomFilter";
              message = {
                id = "recently_added_objects";
                values.objects = mode;
              };
              mode = lib.toUpper mode;
              sortBy = "created_at";
              direction = "DESC";
            };
            presets = {
              recentlyReleasedScenes = recentlyReleased "Scenes";
              recentlyAddedScenes = recentlyAdded "Scenes";
              recentlyReleasedGalleries = recentlyReleased "Galleries";
              recentlyAddedGalleries = recentlyAdded "Galleries";
              recentlyAddedImages = recentlyAdded "Images";
              recentlyReleasedMovies = recentlyReleased "Movies";
              recentlyAddedMovies = recentlyAdded "Movies";
              recentlyAddedStudios = recentlyAdded "Studios";
              recentlyAddedPerformers = recentlyAdded "Performers";
            };
          in [
            presets.recentlyReleasedScenes
            presets.recentlyAddedStudios
            presets.recentlyReleasedMovies
            presets.recentlyAddedPerformers
            presets.recentlyReleasedGalleries
          ];
        };
      };
    };
  };
}
