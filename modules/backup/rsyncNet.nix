{
  lib,
  config,
  ...
}: let
  cfg = config.setup.backup;
in {
  config = lib.mkIf cfg.enable {
    sops.secrets = {
      "ssh/rsync.net/keys/rsync_net" = {
        owner = "root";
        group = "backup";
        mode = "0440";
      };
      "ssh/rsync.net/keys/rsync_net.pub" = {
        owner = "root";
        group = "backup";
        mode = "0444";
      };
    };

    users.groups.backup.members = ["root"] ++ cfg.users;

    systemd.tmpfiles.rules = lib.lists.flatten (map (user: let
        sshDir = "${config.home-manager.users."${user}".home.homeDirectory}/.ssh";
        privKeyPath = config.sops.secrets."ssh/rsync.net/keys/rsync_net".path;
        pubKeyPath = config.sops.secrets."ssh/rsync.net/keys/rsync_net.pub".path;
      in [
        "L+ ${sshDir}/rsync_net 0440 ${user} backup - ${privKeyPath}"
        "L+ ${sshDir}/rsync_net.pub 0444 ${user} backup - ${pubKeyPath}"
      ])
      cfg.users);
  };
}
