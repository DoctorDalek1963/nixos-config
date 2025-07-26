{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.uinput;
in
{
  config = lib.mkIf cfg.enable {
    hardware.uinput.enable = true;

    users.groups.uinput.members = cfg.users;
    users.groups.input.members = cfg.users;
  };
}
