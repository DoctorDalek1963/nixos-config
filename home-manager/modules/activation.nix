{
  lib,
  config,
  ...
}:
let
  mkScript = script: lib.hm.dag.entryAfter [ "writeBoundary" ] script;

  mkSystemdRestart =
    serviceName:
    mkScript ''
      $DRY_RUN_CMD /run/current-system/sw/bin/systemctl restart --user ${serviceName} || true
    '';

  cfg = config.setup;

  restartRcloneMounts = lib.optionalAttrs cfg.rclone.enable (
    builtins.listToAttrs (
      builtins.map (
        { remote, ... }:
        {
          name = "restartRcloneMount${remote}";
          value = mkSystemdRestart "rclone-mount-${lib.strings.toLower remote}";
        }
      ) cfg.rclone.automounts
    )
  );

  restartSopsNix = lib.optionalAttrs cfg.secrets.enable {
    restartSopsNix = mkSystemdRestart "sops-nix";
  };
  restartXremap = lib.optionalAttrs cfg.misc.programs.xremap {
    restartXremap = mkSystemdRestart "xremap";
  };
in
{
  home.activation = restartRcloneMounts // restartSopsNix // restartXremap;
}
