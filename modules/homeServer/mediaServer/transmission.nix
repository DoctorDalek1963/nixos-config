{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    services = {
      nginx.virtualHosts."${cfg.domainName}".locations."/transmission" = {
        proxyPass = "http://localhost:${toString cfg.ports.mediaServer.transmission}";
      };

      transmission = {
        enable = true;
        user = "transmission";
        group = "media";

        # performanceNetParameters = true;

        openRPCPort = true;
        openPeerPorts = true;

        webHome = pkgs.flood-for-transmission;

        settings = {
          download-dir = "${cfgMs.mediaRoot}/torrents/downloads";
          incomplete-dir = "${cfgMs.mediaRoot}/torrents/incomplete";
          downloadDirPermissions = "755";

          # peer-limit-global = 500;

          rpc-enabled = true;
          rpc-port = cfg.ports.mediaServer.transmission;
          rpc-url = "/transmission/";
          rpc-bind-address = "0.0.0.0";

          rpc-username = "";
          rpc-password = "admin";

          rpc-host-whitelist-enabled = false;

          rpc-whitelist-enabled = true;
          rpc-whitelist = lib.concatStringsSep "," [
            # Localhost
            "127.0.0.1"
            "::1"

            # Home network
            "192.168.*.*"

            # Tailnet
            "100.*.*.*"
          ];
        };
      };
    };

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads
      mkdir -p ${cfgMs.mediaRoot}/torrents/incomplete
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents
    '';
  };
}
