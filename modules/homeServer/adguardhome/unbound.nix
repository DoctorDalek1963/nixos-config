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
        num-threads = 2;
      };
    };
  };
}
