{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.backup;
in
{
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

    systemd.tmpfiles.rules = lib.lists.flatten (
      map (
        user:
        let
          sshDir = "${config.home-manager.users."${user}".home.homeDirectory}/.ssh";
          privKeyPath = config.sops.secrets."ssh/rsync.net/keys/rsync_net".path;
          pubKeyPath = config.sops.secrets."ssh/rsync.net/keys/rsync_net.pub".path;
        in
        [
          "L+ ${sshDir}/rsync_net 0440 ${user} backup - ${privKeyPath}"
          "L+ ${sshDir}/rsync_net.pub 0444 ${user} backup - ${pubKeyPath}"
        ]
      ) cfg.users
    );

    programs.ssh.knownHostsFiles = [ ./zh5288.rsync.net.keys ];
  };
}
