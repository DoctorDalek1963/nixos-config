{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf (cfg.enable && cfg.adguardhome.enable) {
    services.unbound = {
      enable = true;

      settings.server = {
        port = cfg.ports.unbound;

        prefetch = true;
        num-threads = 4;

        so-reuseport = true;

        msg-cache-slabs = 4;
        rrset-cache-slabs = 4;
        infra-cache-slabs = 4;
        key-cache-slabs = 4;

        rrset-cache-size = "50m";
        msg-cache-size = "25m";

        outgoing-range = 200;
      };
    };
  };
}
