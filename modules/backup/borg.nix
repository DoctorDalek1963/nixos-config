{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.backup;
in {
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      # Provide borgbackup for users in the backup group
      home-manager.users = builtins.listToAttrs (map (name: {
          inherit name;
          value = {home.packages = [config.services.borgbackup.package];};
        })
        cfg.users);

      setup.impermanence.keepDirs = [
        "/root/.config/borg"
        "/root/.cache/borg"
      ];

      # The key is also defined in sops-secrets/secrets.yaml but not configured
      # here because it only needs to be available in the rare case where I
      # actually need it for recovery
      sops.secrets."borgbackup/repos/rsync.net/nixos-backups/passphrase" = {
        owner = "root";
        group = "backup";
        mode = "0440";
      };

      services.borgbackup.jobs.automatic-rsync-net = lib.mkIf cfg.enable {
        group = "backup";

        inherit (cfg) paths;
        exclude = ["/nix"] ++ cfg.exclude;

        doInit = false;

        dateFormat = "+%Y-%m-%dT%H:%M:%S";
        inhibitsSleep = true;
        archiveBaseName = "${config.setup.hostname}-auto";

        extraArgs = ["--remote-path=borg14"];
        extraCreateArgs = ["--stats" "--checkpoint-interval=600"];

        # An empty list here makes the service not start automatically, but
        # only be triggered manually. When we have no paths, we obviously don't
        # want to do the backup, but we still want to have the script that
        # wraps borg with these credentials in environment variables.
        startAt =
          if builtins.length cfg.paths == 0
          then []
          else cfg.startAt;

        compression = "auto,lzma";
        prune.keep = {
          daily = 7;
          weekly = 4;
        };

        repo = "zh5288@zh5288.rsync.net:nixos-backups";
        encryption = {
          mode = "repokey";
          passCommand = "cat ${config.sops.secrets."borgbackup/repos/rsync.net/nixos-backups/passphrase".path}";
        };

        environment.BORG_RSH = "ssh -i ${config.sops.secrets."ssh/rsync.net/keys/rsync_net".path}";
      };
    })
    (lib.mkIf (cfg.enable && cfg.ntfy.url != null) {
      systemd.services = {
        borgbackup-job-automatic-rsync-net-ntfy-failed = {
          description = "Use ntfy to send a notification that borgbackup-job-automatic-rsync-net failed";
          path = [pkgs.ntfy-sh];

          script = builtins.concatStringsSep " " [
            "ntfy send"
            "--priority high"
            "--tag floppy_disk"
            ''--title "Auto backup failed"''
            "${cfg.ntfy.url}/${cfg.ntfy.topic}"
            ''"Automatic BorgBackup to rsync.net for ${config.setup.hostname} failed"''
          ];
        };

        borgbackup-job-automatic-rsync-net-ntfy-succeeded = {
          description = "Use ntfy to send a notification that borgbackup-job-automatic-rsync-net succeeded";
          path = [pkgs.ntfy-sh];

          script = builtins.concatStringsSep " " [
            "ntfy send"
            "--priority low"
            "--tag floppy_disk"
            ''--title "Auto backup successful"''
            "${cfg.ntfy.url}/${cfg.ntfy.topic}"
            ''"Automatic BorgBackup to rsync.net for ${config.setup.hostname} completed successfully"''
          ];
        };

        borgbackup-job-automatic-rsync-net = {
          onFailure = ["borgbackup-job-automatic-rsync-net-ntfy-failed.service"];
          onSuccess = ["borgbackup-job-automatic-rsync-net-ntfy-succeeded.service"];
        };
      };
    })
  ];
}
