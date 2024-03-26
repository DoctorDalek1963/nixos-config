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

  restartRcloneMounts =
    if cfg.rclone.enable
    then
      builtins.listToAttrs (builtins.map ({remote, ...}: {
          name = "restartRcloneMount${remote}";
          value = mkScript ''
            $DRY_RUN_CMD /run/current-system/sw/bin/systemctl restart --user rclone-mount-${lib.strings.toLower remote}
          '';
        })
        cfg.rclone.automounts)
    else {};

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
in {
  home.activation = restartRcloneMounts // restartSopsNix // restartXremap;
}
