{
  lib,
  config,
  osConfig,
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

  rmHmBackups = let
    home = config.home.homeDirectory;
    backupExt = osConfig.home-manager.backupFileExtension;

    rmBackedUp = filename: "$DRY_RUN_CMD rm -rf ${home}/${filename}.${backupExt}";
  in
    lib.hm.dag.entriesBetween "rmHmBackups" ["linkGeneration"] ["writeBoundary"] (
      lib.optional osConfig.setup.ssh.enable (rmBackedUp ".ssh/known_hosts")
      ++ lib.optional config.setup.librewolf.enable (rmBackedUp ".librewolf/${config.setup.username}/search.json.mozlz4")
    );

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
  home.activation =
    rmHmBackups
    // restartRcloneMounts
    // restartSopsNix
    // restartXremap;
}
