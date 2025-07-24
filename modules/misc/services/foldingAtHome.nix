{
  lib,
  config,
  ...
}: let
  cfg = config.setup.misc.services.foldingAtHome;
in {
  config = lib.mkIf cfg.enable {
    sops.secrets."foldingAtHome/config.xml".mode = "0444";

    services.foldingathome = {
      enable = true;
      daemonNiceLevel = 5;
      extraArgs = [
        "--config=${config.sops.secrets."foldingAtHome/config.xml".path}"
        "--machine-name=${config.setup.hostname}"
      ];
    };
  };
}
