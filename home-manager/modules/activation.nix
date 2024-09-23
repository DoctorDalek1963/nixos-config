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

  mkSystemdRestart = serviceName:
    mkScript ''
      $DRY_RUN_CMD /run/current-system/sw/bin/systemctl restart --user ${serviceName}
    '';

  cfg = config.setup;

  restartRcloneMounts =
    fillIf cfg.rclone.enable
    (builtins.listToAttrs (builtins.map ({remote, ...}: {
        name = "restartRcloneMount${remote}";
        value = mkSystemdRestart "rclone-mount-${lib.strings.toLower remote}";
      })
      cfg.rclone.automounts));

  restartSopsNix = fillIf cfg.secrets.enable {restartSopsNix = mkSystemdRestart "sops-nix";};
  restartXremap = fillIf cfg.misc.programs.xremap {restartXremap = mkSystemdRestart "xremap";};
in {
  home.activation = restartRcloneMounts // restartSopsNix // restartXremap;
}
