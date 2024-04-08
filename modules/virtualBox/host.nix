{
  lib,
  config,
  ...
}: let
  cfg = config.setup.virtualBox.host;
in {
  config = lib.mkIf cfg.enable {
    virtualisation.virtualbox.host.enable = true;
    users.groups.vboxusers.members = cfg.users;
  };
}
