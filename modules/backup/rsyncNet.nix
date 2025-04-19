{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.backup;
in {
  config = lib.mkIf cfg.enable {
    # These secrets are owned by nobody and group readable so that any user in
    # the backup group can use them, for example in the generated wrapper
    # script that uses BORG_RSH. The reason they have to be owned by nobody is
    # because openssh doesn't lack lax permission, like group readability. But
    # it only does the permissions check if the current user owns the file.
    # Otherwise, it just tries to read it. Since nobody owns these files, any
    # user in backup can read them!
    sops.secrets = {
      "ssh/rsync.net/keys/rsync_net" = {
        owner = "nobody";
        group = "backup";
        mode = "0040";
      };
      "ssh/rsync.net/keys/rsync_net.pub" = {
        owner = "nobody";
        group = "backup";
        mode = "0040";
      };
    };

    systemd.tmpfiles.rules = lib.lists.flatten (map (user: let
        sshDir = "${config.home-manager.users."${user}".home.homeDirectory}/.ssh";
        privKeyPath = config.sops.secrets."ssh/rsync.net/keys/rsync_net".path;
        pubKeyPath = config.sops.secrets."ssh/rsync.net/keys/rsync_net.pub".path;
      in [
        "L+ ${sshDir}/rsync_net 0440 ${user} backup - ${privKeyPath}"
        "L+ ${sshDir}/rsync_net.pub 0444 ${user} backup - ${pubKeyPath}"
      ])
      cfg.users);

    programs.ssh.knownHostsFiles = [
      (pkgs.writeText "zh5288.rsync.net.keys" ''
        zh5288.rsync.net ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIJtclizeBy1Uo3D86HpgD3LONGVH0CJ0NT+YfZlldAJd
        zh5288.rsync.net ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBLR2uz+YLn2KiQK0Luu8rhfWS6LHgUfGAWB1j8rM2MKn4KZ2/LhIX1CYkPKMTPxHr6mzayeL1T1hyJIylxXv0BY=
        zh5288.rsync.net ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQDPgHxQyaDaVxUefoUJZO/lITh0Gp0sqbP7HejQcCfZi7gAcuM6/IAuUXLHFImefCHh52x6T/cHxgL1qz26GKgdxykl06WRXlRIuE45QFSy/cd9JKr6l58fKq30ApmXRsCNwFrMlFPoEpCTqxzddZ9cLXs1Yt9dRxvFlQVEuAzw7ayvt8DE6RP9/CHYVp54wbbvUToECGwu70sxY1vFg51K+vNpvJ3J0t5j3s4c1Wls4BrIwqi2U8kqCq9Nj2CUIQqjM+93CSqEacR3qOGvG/6QMzd733wzpJ/iZee+lcyTYzA0YNMosnaF01hrv7NMwtZ6xRFLlJZtMZ7JpfySrOBr
      '')
    ];
  };
}
