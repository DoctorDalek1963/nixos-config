{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.androidTools;
in
{
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [ pkgs.android-tools ];

    users.groups.plugdev.members = cfg.users;

    programs.droidcam.enable = cfg.droidcam;
  };
}
