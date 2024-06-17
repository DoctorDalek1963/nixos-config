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
        icon = "adguard-home";
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
    list = lib.optionals cfg.mediaServer.enable [
      {
        "Transmission" = {
          icon = "transmission";
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
          icon = "prowlarr";
          href = "https://${cfg.domainName}/prowlarr";
          description = "Torrent & Usenet indexer manager";
          widget = {
            type = "prowlarr";
            url = href;
            key = "{{HOMEPAGE_VAR_PROWLARR_KEY}}";
          };
        };
      }
    ];
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
        openFirewall = true;

        bookmarks =
          [
            {
              "Admin tools" = [
                {
                  Tailscale = [
                    {
                      abbr = "TS";
                      icon = "tailscale";
                      href = "https://login.tailscale.com/admin/machines";
                      description = "";
                    }
                  ];
                }
              ];
            }
          ]
          ++ personalProjectsBookmarks;
        services = infraServices ++ mediaServices;

        settings = {headerStyle = "boxed";};
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
