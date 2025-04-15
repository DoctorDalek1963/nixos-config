{
  pkgs,
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

    programs.ssh.knownHostsFiles = [
      (pkgs.writeText "zh5288.rsync.net.keys" ''
        zh5288.rsync.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtclizeBy1Uo3D86HpgD3LONGVH0CJ0NT+YfZlldAJd
        zh5288.rsync.net ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLR2uz+YLn2KiQK0Luu8rhfWS6LHgUfGAWB1j8rM2MKn4KZ2/LhIX1CYkPKMTPxHr6mzayeL1T1hyJIylxXv0BY=
        zh5288.rsync.net ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPgHxQyaDaVxUefoUJZO/lITh0Gp0sqbP7HejQcCfZi7gAcuM6/IAuUXLHFImefCHh52x6T/cHxgL1qz26GKgdxykl06WRXlRIuE45QFSy/cd9JKr6l58fKq30ApmXRsCNwFrMlFPoEpCTqxzddZ9cLXs1Yt9dRxvFlQVEuAzw7ayvt8DE6RP9/CHYVp54wbbvUToECGwu70sxY1vFg51K+vNpvJ3J0t5j3s4c1Wls4BrIwqi2U8kqCq9Nj2CUIQqjM+93CSqEacR3qOGvG/6QMzd733wzpJ/iZee+lcyTYzA0YNMosnaF01hrv7NMwtZ6xRFLlJZtMZ7JpfySrOBr
      '')
    ];

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
