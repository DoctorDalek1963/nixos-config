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
    setup.impermanence.keepDirs = [config.services.speakarr.dataDir];

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

        settings = {
          app.instancename = "Speakarr";
          server = {
            port = cfg.ports.mediaServer.speakarr;
            urlbase = "speakarr";
          };
          auth = {
            required = "Enabled";
            method = "Basic";
          };
        };
      };
    };

    systemd = {
      services.speakarr = {
        after = ["servarr-config.service"];
        requires = ["servarr-config.service"];
      };

      tmpfiles.settings.books."${cfgMs.mediaRoot}/torrents/downloads/audiobooks".d = {
        user = "transmission";
        group = "media";
        mode = "775";
      };
    };
  };
}
