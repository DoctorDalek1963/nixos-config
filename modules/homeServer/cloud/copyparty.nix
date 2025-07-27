{
  lib,
  config,
  inputs,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgCp = cfg.cloud.copyparty;
in
{
  imports = [ inputs.copyparty.nixosModules.default ];

  config = lib.mkIf (cfg.enable && cfgCp.enable) {
    nixpkgs.overlays = [ inputs.copyparty.overlays.default ];

    setup.backup.paths = [ cfgCp.cloudRoot ];
    sops.secrets."home-server/copyparty/dyson/password".mode = "0444";
    users.groups.copyparty.members = [ cfg.manager ];

    services = {
      copyparty = {
        enable = true;

        settings = {
          i = [ "127.0.0.1" ];
          p = [ cfg.ports.cloud.copyparty ];

          zm = true; # zeroconf mDNS
          z-on = [ "100.0.0.0/8" ]; # Only do zeroconf for 100.*.*.* addresses

          e2dsa = true; # File indexing, scan all
          e2ts = true; # Metadata indexing, scan new

          rp-loc = "/copyparty"; # Reverse proxy location
        };

        accounts.dyson.passwordFile = config.sops.secrets."home-server/copyparty/dyson/password".path;

        volumes."/" = {
          path = cfgCp.cloudRoot;
          access.A = [ "dyson" ];
          flags = { };
        };
      };

      nginx = {
        upstreams.copyparty_tcp = {
          servers."127.0.0.1:${toString cfg.ports.cloud.copyparty}" = {
            fail_timeout = "1s";
          };

          extraConfig = ''
            keepalive 1;
          '';
        };

        virtualHosts."${cfg.domainName}".locations."/copyparty" = {
          proxyPass = "http://copyparty_tcp/copyparty";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };
      };
    };
  };
}
