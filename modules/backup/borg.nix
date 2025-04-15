{
  lib,
  config,
  ...
}: let
  cfg = config.setup.backup;
in {
  config = lib.mkIf cfg.enable {
    # Provide borgbackup for users in the backup group
    home-manager.users = builtins.listToAttrs (map (name: {
        inherit name;
        value = {home.packages = [config.services.borgbackup.package];};
      })
      cfg.users);

    # The key is also defined in sops-secrets/secrets.yaml but not configured
    # here because it only needs to be available in the rare case where I
    # actually need it for recovery
    sops.secrets."borgbackup/repos/rsync.net/nixos-backups/passphrase" = {
      owner = "root";
      group = "backup";
      mode = "0440";
    };

    services.borgbackup.jobs.automatic-rsync-net =
      lib.mkIf
      (cfg.enable && builtins.length cfg.paths > 0) {
        inherit (cfg) paths;
        exclude = ["/nix"] ++ cfg.exclude;

        doInit = false;

        dateFormat = "+%Y-%m-%dT%H:%M:%S";
        inhibitsSleep = true;
        archiveBaseName = "${config.setup.hostname}-auto";
        # extraArgs = "--remote-path=borg14";

        repo = "zh5288@zh5288.rsync.net:nixos-backups";
        encryption = {
          mode = "repokey";
          passCommand = "cat ${config.sops.secrets."borgbackup/repos/rsync.net/nixos-backups/passphrase".path}";
        };

        environment = {
          BORG_RSH = "ssh -i ${config.sops.secrets."ssh/rsync.net/keys/rsync_net".path}";
        };

        compression = "auto,lzma";
        inherit (cfg) startAt;

        prune.keep = {
          daily = 7;
          weekly = 4;
        };
      };
  };
}
