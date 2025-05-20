{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  stashapp-tools = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "stashapp-tools";
    version = "0.2.58";
    pyproject = true;

    src = pkgs.fetchPypi {
      inherit pname version;
      hash = "sha256-krruLbBI4FMruoXPiJEde9403hY7se6aeDsO+AqA8jo=";
    };

    build-system = [pkgs.python3.pkgs.setuptools];

    dependencies = [pkgs.python3.pkgs.requests];
  };

  python = pkgs.python3.withPackages (p: [stashapp-tools p.pyyaml]);
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.porn) {
    setup = {
      impermanence.keepDirs = [config.services.stash.dataDir];

      backup = {
        paths = [config.services.stash.dataDir];
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
      "home-server/stash/api-key" = perms;
    };

    systemd.services.stash.serviceConfig = {
      # We want plugins to be able to change files, like renaming them
      BindReadOnlyPaths = lib.mkForce [];

      ExecStartPre = [
        (
          let
            inherit (config.services.stash.settings) plugins_path;
          in
            pkgs.writeShellScript "copy-stash-plugins.sh" ''
              mkdir -p ${plugins_path}
              cp -r ${(import ./plugins {inherit pkgs;}).outPath}/* ${plugins_path}/
              chown -R ${config.services.stash.user}:media ${plugins_path}
              chmod -R u+rw,g+rw ${plugins_path}
            ''
        )
        (let
          script = pkgs.writeShellScript "set-stash-api-key.sh" ''
            env apiKey="$(< ${config.sops.secrets."home-server/stash/api-key".path})" \
              ${lib.getExe pkgs.yq-go} -i '.api_key = strenv(apiKey)' ${config.services.stash.dataDir}/config.yml
          '';
          # Why the plus? So that this script is run as root and we can actually read the secret API key
        in "+${script}")
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
            proxy_set_header X-Forwarded-Prefix /stash;

            rewrite ^/stash/(.*)$ /$1 break;
          '';
        };
      };

      stash = {
        enable = true;
        group = "media";

        # TODO (stash 0.29): We should be able to remove this patch once
        # https://github.com/stashapp/stash/pull/5791 lands in a release
        package = pkgs.stash.overrideAttrs (oldAttrs: {
          patches = (oldAttrs.patches or []) ++ [./hls-dash-streaming-segments.patch];
        });

        username = "dyson";
        passwordFile = config.sops.secrets."home-server/stash/password".path;
        jwtSecretKeyFile = config.sops.secrets."home-server/stash/jwt-secret".path;
        sessionStoreKeyFile = config.sops.secrets."home-server/stash/session-store-secret".path;

        mutableSettings = true; # TODO (nixos module): Logic is nixpkgs is backwards until https://github.com/NixOS/nixpkgs/pull/408198 is merged
        mutablePlugins = false;
        mutableScrapers = true; # I can't be bothered to declare all of these

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
          plugins_path = lib.mkForce "${config.services.stash.dataDir}/plugins";
          language = "en-GB";

          ffmpeg.hardware_acceleration = true;
          ffmpeg_path = "${pkgs.jellyfin-ffmpeg}/bin/ffmpeg";
          ffprobe_path = "${pkgs.jellyfin-ffmpeg}/bin/ffprobe";
          python_path = "${python}/bin/python3";
          scraper_cdp_path = "${pkgs.ungoogled-chromium}/bin/chromium";

          menu_items = [
            "scenes"
            "groups"
            "performers"
            "studios"
            "tags"
          ];

          ui = {
            advancedMode = true;

            taskDefaults = {
              autoTag = {
                performers = [];
                studios = [];
                tags = [];
              };

              scan = {
                rescan = true;
                scanGenerateClipPreviews = false;
                scanGenerateCovers = true;
                scanGenerateImagePreviews = false;
                scanGeneratePhashes = false;
                scanGeneratePreviews = true;
                scanGenerateSprites = true;
                scanGenerateThumbnails = false;
              };
            };

            showChildStudioContent = true;
            ratingSystemOptions.type = "decimal";

            # This *should* be the default, but it seems like it won't build
            # using the default settings because they use some fancy `apply`
            # option to work with a function, but that causes the generation of
            # config.yml to fail, which causes the whole system build to fail.
            # Looks like https://github.com/NixOS/nixpkgs/pull/402574 should fix
            # this and issue with empty plugin/scraper lists
            frontPageContent = let
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
  };
}
