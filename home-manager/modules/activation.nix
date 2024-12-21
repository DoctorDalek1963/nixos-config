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

  # This actually removes the file after we back it up. So
  # known_hosts.hm-backup gets created and deleted every time we switch a new
  # config. But this is way better than having to manually remove it all the time
  rmSshKnownHosts = fillIf osConfig.setup.ssh.enable {
    rmSshKnownHosts = let
      filename = ".ssh/known_hosts.${osConfig.home-manager.backupFileExtension}";
    in
      mkScript "$DRY_RUN_CMD rm -f ${config.home.homeDirectory}/${filename}";
  };

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
    rmSshKnownHosts
    // restartRcloneMounts
    // restartSopsNix
    // restartXremap;
}
