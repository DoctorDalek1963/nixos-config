{
  lib,
  config,
  ...
}: let
  cfg = config.setup.backup;
in {
  imports = [./borg.nix ./rsyncNet.nix];

  config = lib.mkIf cfg.enable {
    users.groups.backup.members = ["root"] ++ cfg.users;
  };
}
