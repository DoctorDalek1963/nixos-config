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

        # TODO (25.05): Uncomment these when the borg service expands extraArgs properly
        # extraArgs = ["--remote-path=borg14"];
        # extraCreateArgs = ["--stats" "--checkpoint-interval 600"]

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

        # This is bizarre. Basically, the SSH private key for rsync.net has
        # mode 0440 so that any user in the backup group (like my normal user)
        # can access it. For those users, this is fine. But for some reason,
        # when running the systemd service, we get an SSH error that the
        # permissions are too open.

        # I believe this is because the service is run as root and the private
        # key is owned by root, but even if I make a new user specifically to
        # own the key, I still get the permission error. Perhaps it only works
        # for normal users because I symlink the keys to ~/.ssh.

        # Either way, copying the private key and changing the mode works as a
        # little hack just for the service.
        preHook = ''
          sshKeyDir="$(mktemp -d)"
          trap "rm -rf $sshKeyDir" EXIT

          cp ${config.sops.secrets."ssh/rsync.net/keys/rsync_net".path} $sshKeyDir/rsync_net
          chmod 0400 $sshKeyDir/rsync_net

          export BORG_RSH="ssh -i $sshKeyDir/rsync_net"
        '';
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
