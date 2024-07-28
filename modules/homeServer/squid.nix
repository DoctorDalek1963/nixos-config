{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf (cfg.enable && cfg.squid.enable) {
    services.squid = {
      enable = true;
      proxyPort = cfg.ports.squid;
      extraConfig = ''
        acl localnet src 100.0.0.0/8 # Listen on my tailnet
      '';
    };
  };
}
