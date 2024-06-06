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
in {
  config = lib.mkIf cfg.enable {
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations."/" = {
        proxyPass = "http://localhost:${toString cfg.ports.homepage}";
      };

      homepage-dashboard = {
        enable = true;

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
        services = infraServices;

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
