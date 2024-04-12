{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.androidTools;
in {
  config = lib.mkIf cfg.enable {
    environment.systemPackages = [pkgs.android-tools];

    services.udev = {
      enable = true;
      packages = [pkgs.android-udev-rules];
    };

    users.groups.plugdev.members = cfg.users;

    programs.droidcam.enable = cfg.droidcam;
  };
}
