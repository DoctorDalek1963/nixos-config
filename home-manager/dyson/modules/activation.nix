{
  lib,
  config,
  ...
}: let
  fillIf = condition: content:
    if condition
    then content
    else {};
  mkScript = script: lib.hm.dag.entryAfter ["writeBoundary"] script;

  cfg = config.setup;

  restartSopsNix = fillIf cfg.secrets {
    restartSopsNix = mkScript ''
      $DRY_RUN_CMD /run/current-system/sw/bin/systemctl restart --user sops-nix
    '';
  };

  restartXremap = fillIf cfg.miscPrograms.xremap {
    restartXremap = mkScript ''
      $DRY_RUN_CMD /run/current-system/sw/bin/systemctl restart --user xremap
    '';
  };
  # TODO: How can I restart all the rclone mount services?
in {
  home.activation = restartSopsNix // restartXremap;
}
