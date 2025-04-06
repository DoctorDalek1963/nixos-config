{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
  cfgPp = cfg.personalProjects;

  # Information about how the icons work can be found at
  # https://gethomepage.dev/latest/configs/services/#icons

  # TODO (25.05): Redo all config for v0.9 -> v1 update

  miscBookmarks = let
    list = lib.optional cfg.firefly-iii.enable {
      "Firefly III" = [
        {
          abbr = "FIII";
          icon = "firefly.png";
          href = "https://${cfg.domainName}/firefly-iii/home";
          description = "";
        }
      ];
    };
  in
    if builtins.length list > 0
    then [{Misc = list;}]
    else [];

  personalProjectsBookmarks = let
    list =
      lib.optional cfgPp.tictactoe {
        Tictactoe = [
          {
            abbr = "TTT";
            icon = "https://raw.githubusercontent.com/DoctorDalek1963/tic-tac-toe/main/favicon.ico";
            href = "https://${cfg.domainName}/tictactoe";
            description = "";
          }
        ];
      }
      ++ lib.optional cfgPp.winter-wonderlights {
        "Winter WonderLights" = [
          {
            abbr = "WW";
            href = "https://${cfg.domainName}/winter-wonderlights";
            description = "";
          }
        ];
      }
      ++ lib.optional cfgPp.wordle {
        Wordle = [
          {
            abbr = "WD";
            icon = "https://raw.githubusercontent.com/DoctorDalek1963/wordle/main/web/favicon.ico";
            href = "https://${cfg.domainName}/wordle";
            description = "";
          }
        ];
      };
  in
    if cfgPp.enable && builtins.length list > 0
    then [{"Personal projects" = list;}]
    else [];

  infraServices = let
    list =
      (lib.optional cfg.adguardhome.enable {
        "AdGuard Home" = {
          icon = "adguard-home.svg";
          href = "https://${cfg.domainName}:${toString cfg.ports.adguardhome.https}/";
          description = "DNS-level ad blocker";
          widget = {
            type = "adguard";
            url = "https://localhost:${toString cfg.ports.adguardhome.https}";
          };
        };
      })
      ++ (lib.optional cfg.myspeed.enable {
        "MySpeed" = {
          icon = "mdi-speedometer";
          href = "https://${cfg.domainName}:${toString cfg.ports.haproxy.myspeed}/";
          description = "Speedtest aggregator and analyzer";
          widget = {
            type = "myspeed";
            url = "http://localhost:${toString cfg.ports.myspeed}";
          };
        };
      });
  in
    if builtins.length list > 0
    then [{Infrastructure = list;}]
    else [];

  mediaServices = let
    list = lib.optionals cfgMs.enable (
      (
        lib.optionals (cfgMs.movies || cfgMs.telly) [
          {
            "Jellyfin" = {
              icon = "jellyfin.svg";
              href = "https://${cfg.domainName}/jellyfin";
              description = "Movie and TV streaming";
              widget = {
                type = "jellyfin";
                url = "http://localhost:${toString cfg.ports.mediaServer.jellyfin.http}/jellyfin";
                key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
                enableBlocks = true;
                enableNowPlaying = true;
                enableUser = true;
                showEpisodeNumber = true;
                expandOneStreamToTwoRows = true;
              };
            };
          }
          {
            "Jellyseerr" = {
              icon = "jellyseerr.svg";
              href = "https://${cfg.domainName}:${toString cfg.ports.haproxy.mediaServer.jellyseerr}";
              description = "Request movies and TV shows";
              widget = {
                type = "jellyseerr";
                url = "http://localhost:${toString cfg.ports.mediaServer.jellyseerr}";
                key = "{{HOMEPAGE_VAR_JELLYSEERR_KEY}}";
              };
            };
          }
        ]
      )
      ++ (
        lib.optional cfgMs.music
        {
          "Navidrome" = {
            icon = "navidrome.svg";
            href = "https://${cfg.domainName}/navidrome";
            description = "Music streaming";
            widget = {
              type = "navidrome";
              url = "http://localhost:${toString cfg.ports.mediaServer.navidrome}/navidrome";
              user = "admin";
              token = "4d1618495ed3495dcb95d7d8511e7717";
              salt = "gt8ou69prf";
            };
          };
        }
      )
      ++ (lib.optionals cfgMs.books [
        {
          "Calibre" = {
            icon = "calibre.svg";
            href = "https://${cfg.domainName}/calibre";
            description = "Digital library";
            widget = {
              type = "calibreweb";
              url = "http://localhost:${toString cfg.ports.mediaServer.calibre.web}";
              username = "admin";
              password = "admin123";
            };
          };
        }
        {
          "Audiobookshelf" = {
            icon = "audiobookshelf.svg";
            href = "https://${cfg.domainName}:${toString cfg.ports.haproxy.mediaServer.audiobookshelf}";
            description = "Digital audiobook library";
            widget = {
              type = "audiobookshelf";
              url = "http://localhost:${toString cfg.ports.mediaServer.audiobookshelf}";
              key = "{{HOMEPAGE_VAR_AUDIOBOOKSHELF_KEY}}";
            };
          };
        }
      ])
    );
  in
    if builtins.length list > 0
    then [{Media = list;}]
    else [];

  mediaDownloadServices = let
    list = lib.optionals cfgMs.enable (
      [
        {
          "Transmission" = {
            icon = "transmission.svg";
            href = "https://${cfg.domainName}/transmission";
            description = "BitTorrent client";
            widget = {
              type = "transmission";
              url = "http://192.168.${toString cfgMs.transmission.thirdOctet}.2:${toString cfg.ports.mediaServer.transmission}";
              username = config.services.transmission.settings.rpc-username;
              password = config.services.transmission.settings.rpc-password;
              rpc-url = "/transmission/";
            };
          };
        }
        {
          "Prowlarr" = {
            icon = "prowlarr.svg";
            href = "https://${cfg.domainName}/prowlarr";
            description = "Torrent & Usenet indexer manager";
            widget = {
              type = "prowlarr";
              url = "http://localhost:${toString cfg.ports.mediaServer.prowlarr}/prowlarr";
              key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
            };
          };
        }
      ]
      ++ (
        lib.optional cfgMs.movies
        {
          "Radarr" = {
            icon = "radarr.svg";
            href = "https://${cfg.domainName}/radarr";
            description = "Movie manager";
            widget = {
              type = "radarr";
              url = "http://localhost:${toString cfg.ports.mediaServer.radarr}/radarr";
              key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
            };
          };
        }
      )
      ++ (
        lib.optional cfgMs.telly
        {
          "Sonarr" = {
            icon = "sonarr.svg";
            href = "https://${cfg.domainName}/sonarr";
            description = "TV manager";
            widget = {
              type = "sonarr";
              url = "http://localhost:${toString cfg.ports.mediaServer.sonarr}/sonarr";
              key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
            };
          };
        }
      )
      ++ (
        lib.optional (cfgMs.movies || cfgMs.telly)
        {
          "Bazarr" = {
            icon = "bazarr.svg";
            href = "https://${cfg.domainName}/bazarr";
            description = "Subtitle manager";
            widget = {
              type = "bazarr";
              url = "http://localhost:${toString cfg.ports.mediaServer.bazarr}/bazarr";
              key = "{{HOMEPAGE_VAR_BAZARR_KEY}}";
            };
          };
        }
      )
      ++ (
        lib.optional cfgMs.music
        {
          "Lidarr" = {
            icon = "lidarr.svg";
            href = "https://${cfg.domainName}/lidarr";
            description = "Music manager";
            widget = {
              type = "lidarr";
              url = "http://localhost:${toString cfg.ports.mediaServer.lidarr}/lidarr";
              key = "{{HOMEPAGE_VAR_LIDARR_KEY}}";
            };
          };
        }
      )
      ++ (
        lib.optionals cfgMs.books [
          {
            "Readarr" = {
              icon = "readarr.svg";
              href = "https://${cfg.domainName}/readarr";
              description = "E-book manager";
              widget = {
                type = "readarr";
                url = "http://localhost:${toString cfg.ports.mediaServer.readarr}/readarr";
                key = "{{HOMEPAGE_VAR_READARR_KEY}}";
              };
            };
          }
          {
            "Speakarr" = {
              icon = "mdi-cast-audio-variant";
              href = "https://${cfg.domainName}/speakarr";
              description = "Audiobook manager";
              widget = {
                type = "readarr";
                url = "http://localhost:${toString cfg.ports.mediaServer.speakarr}/speakarr";
                key = "{{HOMEPAGE_VAR_SPEAKARR_KEY}}";
              };
            };
          }
        ]
      )
    );
  in
    if builtins.length list > 0
    then [{"Media downloading" = list;}]
    else [];
in {
  config = lib.mkIf cfg.enable {
    sops.secrets."home-server/homepage.env" = {
      mode = "0400";
    };

    services = {
      nginx.virtualHosts."${cfg.domainName}".locations."/" = {
        proxyPass = "http://localhost:${toString cfg.ports.homepage}";
      };

      homepage-dashboard = {
        enable = true;

        environmentFile = config.sops.secrets."home-server/homepage.env".path;
        listenPort = cfg.ports.homepage;

        bookmarks = miscBookmarks ++ personalProjectsBookmarks;
        services = infraServices ++ mediaServices ++ mediaDownloadServices;

        settings = {
          headerStyle = "boxed";
          iconStyle = "theme";

          layout = [
            {
              Infrastructure = {
                style = "row";
                columns = 2;
                icon = "mdi-server";
              };
            }
            {
              Media = let
                optNum = cond: num:
                  if cond
                  then num
                  else 0;
                cols =
                  (optNum (cfgMs.movies || cfgMs.telly) 2)
                  + (optNum cfgMs.music 1)
                  + (optNum cfgMs.books 2);
              in {
                style = "row";
                columns =
                  {
                    "1" = 1;
                    "2" = 2;
                    "3" = 3;
                    "4" = 2;
                    "5" = 3;
                  }
                  .${toString cols};
                icon = "si-jellyfin";
              };
            }
            {
              "Media downloading" = {
                style = "row";
                columns = 3;
                icon = "mdi-download";
              };
            }
            {
              Misc = {
                style = "row";
                columns = 2;
                icon = "mdi-cog-box";
              };
            }
            {
              "Personal projects" = {
                style = "row";
                columns = 2;
                icon = "mdi-account-wrench";
              };
            }
          ];
        };

        widgets = [
          {
            search = {
              provider = "duckduckgo";
              target = "_blank";
            };
          }
          {
            resources =
              {
                label = "system";
                cpu = true;
                memory = true;
                cputemp = true;
                units = "metric";
                uptime = true;
              }
              // {
                "Bert-NixOS" = {
                  tempmin = 40;
                  tempmax = 85;
                };
              }
              .${config.setup.hostname};
          }
          {
            resources = {
              label = "storage";
              disk = ["/"];
            };
          }
          {
            openmeteo = {
              units = "metric";
              cache = 5; # Minutes
            };
          }
        ];
      };
    };
  };
}
