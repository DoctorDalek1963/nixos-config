{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
in {
  config = lib.mkIf (cfg.enable && cfg.foldingAtHome.enable) {
    sops.secrets."home-server/foldingAtHome/config.xml".mode = "0444";

    services.foldingathome = {
      enable = true;
      daemonNiceLevel = 5;
      extraArgs = [
        "--config=${config.sops.secrets."home-server/foldingAtHome/config.xml".path}"
        "--machine-name=${config.setup.hostname}"
      ];
    };
  };
}
