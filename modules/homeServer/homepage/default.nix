{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgPp = cfg.personalProjects;

  optList = cond: item:
    if cond
    then [item]
    else [];

  # Information about how the icons work can be found at
  # https://gethomepage.dev/latest/configs/services/#icons

  personalProjectsBookmarks =
    if cfgPp.enable && builtins.length personalProjectsList > 0
    then [{"Personal projects" = personalProjectsList;}]
    else [];
  personalProjectsList =
    optList cfgPp.tictactoe {
      Tictactoe = [
        {
          abbr = "TTT";
          icon = "https://raw.githubusercontent.com/DoctorDalek1963/tic-tac-toe/main/favicon.ico";
          href = "https://${cfg.domainName}/tictactoe";
          description = "";
        }
      ];
    }
    ++ optList cfgPp.winter-wonderlights {
      "Winter WonderLights" = [
        {
          abbr = "WW";
          href = "https://${cfg.domainName}/winter-wonderlights";
          description = "";
        }
      ];
    }
    ++ optList cfgPp.wordle {
      Wordle = [
        {
          abbr = "WD";
          icon = "https://raw.githubusercontent.com/DoctorDalek1963/wordle/main/web/favicon.ico";
          href = "https://${cfg.domainName}/wordle";
          description = "";
        }
      ];
    };

  infraServices = let
    list = optList cfg.adguardhome.enable {
      "AdGuard Home" = rec {
        icon = "adguard-home.svg";
        href = "https://${cfg.domainName}:${toString cfg.ports.adguardhome.https}/";
        description = "DNS-level ad blocker";
        widget = {
          type = "adguard";
          url = href;
        };
      };
    };
  in
    if builtins.length list > 0
    then [{Infrastructure = list;}]
    else [];

  mediaServices = let
    list = lib.optionals cfg.mediaServer.enable (
      [
        {
          "Transmission" = {
            icon = "transmission.svg";
            href = "https://${cfg.domainName}/transmission";
            description = "BitTorrent client";
            widget = {
              type = "transmission";
              url = "http://192.168.${toString cfg.mediaServer.transmission.thirdOctet}.2:${toString cfg.ports.mediaServer.transmission}";
              username = config.services.transmission.settings.rpc-username;
              password = config.services.transmission.settings.rpc-password;
              rpc-url = "/transmission/";
            };
          };
        }
        {
          "Prowlarr" = rec {
            icon = "prowlarr.svg";
            href = "https://${cfg.domainName}/prowlarr";
            description = "Torrent & Usenet indexer manager";
            widget = {
              type = "prowlarr";
              url = href;
              key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
            };
          };
        }
      ]
      ++ (
        lib.optional (cfg.mediaServer.movies || cfg.mediaServer.telly)
        {
          "Jellyfin" = rec {
            icon = "jellyfin.svg";
            href = "https://${cfg.domainName}/jellyfin";
            description = "Movie and TV streaming";
            widget = {
              type = "jellyfin";
              url = href;
              key = "{{HOMEPAGE_VAR_JELLYFIN_KEY}}";
              enableBlocks = true;
              enableNowPlaying = true;
              enableUser = true;
              showEpisodeNumber = true;
              expandOneStreamToTwoRows = true;
            };
          };
        }
      )
      ++ (
        lib.optional cfg.mediaServer.movies
        {
          "Radarr" = rec {
            icon = "radarr.svg";
            href = "https://${cfg.domainName}/radarr";
            description = "Movie manager";
            widget = {
              type = "radarr";
              url = href;
              key = "{{HOMEPAGE_VAR_RADARR_KEY}}";
            };
          };
        }
      )
      ++ (
        lib.optional cfg.mediaServer.telly
        {
          "Sonarr" = rec {
            icon = "sonarr.svg";
            href = "https://${cfg.domainName}/sonarr";
            description = "TV manager";
            widget = {
              type = "sonarr";
              url = href;
              key = "{{HOMEPAGE_VAR_SONARR_KEY}}";
            };
          };
        }
      )
      ++ (lib.optionals cfg.mediaServer.music [
        {
          "Lidarr" = rec {
            icon = "lidarr.svg";
            href = "https://${cfg.domainName}/lidarr";
            description = "Music manager";
            widget = {
              type = "lidarr";
              url = href;
              key = "{{HOMEPAGE_VAR_LIDARR_KEY}}";
            };
          };
        }
        {
          "Navidrome" = rec {
            icon = "navidrome.svg";
            href = "https://${cfg.domainName}/navidrome";
            description = "Music streaming";
            widget = {
              type = "navidrome";
              url = href;
              user = "admin";
              token = "4d1618495ed3495dcb95d7d8511e7717";
              salt = "gt8ou69prf";
            };
          };
        }
      ])
      ++ (lib.optionals cfg.mediaServer.books [
        {
          "Readarr" = rec {
            icon = "readarr.svg";
            href = "https://${cfg.domainName}/readarr";
            description = "E-book and audiobook manager";
            widget = {
              type = "readarr";
              url = href;
              key = "{{HOMEPAGE_VAR_READARR_KEY}}";
            };
          };
        }
        {
          "Calibre" = rec {
            icon = "calibre.svg";
            href = "https://${cfg.domainName}/calibre";
            description = "Digital library";
            widget = {
              type = "calibreweb";
              url = href;
              username = "admin";
              password = "admin123";
            };
          };
        }
      ])
    );
  in
    if builtins.length list > 0
    then [{Media = list;}]
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

        bookmarks = personalProjectsBookmarks;
        services = infraServices ++ mediaServices;

        settings = {
          headerStyle = "boxed";
          iconStyle = "theme";

          layout = [
            {
              Media = {
                style = "row";
                columns = 4;
                icon = "si-jellyfin";
              };
            }
            {
              Infrastructure = {
                style = "row";
                columns = 2;
                icon = "mdi-server";
              };
            }
            {
              "Admin tools" = {
                style = "row";
                columns = 2;
                icon = "mdi-cog";
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
            resources = {
              label = "system";
              cpu = true;
              memory = true;
            };
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
