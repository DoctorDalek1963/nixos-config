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

  personalProjectsBookmarks =
    if cfgPp.enable && builtins.length personalProjectsList > 0
    then [{"Personal projects" = personalProjectsList;}]
    else [];
  personalProjectsList =
    optList cfgPp.tictactoe {
      Tictactoe = [
        {
          abbr = "TTT";
          href = "https://${cfg.domainName}/tictactoe";
          description = "Tic-tac-toe";
        }
      ];
    }
    ++ optList cfgPp.winter-wonderlights {
      "Winter WonderLights" = [
        {
          abbr = "WW";
          href = "https://${cfg.domainName}/winter-wonderlights";
          description = "Winter WonderLights";
        }
      ];
    }
    ++ optList cfgPp.wordle {
      Wordle = [
        {
          abbr = "WD";
          href = "https://${cfg.domainName}/wordle";
          description = "Wordle";
        }
      ];
    };

  infraServices = let
    list = optList cfg.adguardhome.enable {
      "AdGuard Home" = rec {
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
                      href = "https://login.tailscale.com/admin/machines";
                      description = "Tailscale dashboard";
                    }
                  ];
                }
              ];
            }
          ]
          ++ personalProjectsBookmarks;
        services = infraServices;

        settings = {headerStyle = "clean";}; # Why doesn't this work?
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
