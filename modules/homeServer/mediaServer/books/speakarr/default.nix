{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  imports = [./options.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.books) {
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations = {
        "/speakarr" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.speakarr}";
          extraConfig = ''
            proxy_redirect off;
            proxy_http_version 1.1;
            proxy_set_header Upgrade $http_upgrade;
            proxy_set_header Connection $http_connection;
          '';
        };

        "~ /speakarr/api" = {
          proxyPass = "http://localhost:${toString cfg.ports.mediaServer.speakarr}";
          extraConfig = "auth_basic off;";
        };
      };

      speakarr = {
        enable = true;
        group = "media";
      };
    };

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads/audiobooks
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents/downloads/audiobooks
    '';

    systemd.services.speakarr = {
      after = ["servarr-config.service"];
      requires = ["servarr-config.service"];
    };
  };
}
