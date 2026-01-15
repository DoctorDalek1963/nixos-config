{
  pkgs,
  lib,
  config,
  ...
}:
let
  waydroid = pkgs.waydroid-nftables;
in
{
  config = lib.mkIf config.setup.desktopEnvironments.androidTv.enable {
    virtualisation.waydroid = {
      enable = true;
      package = waydroid;
    };

    # users.extraUsers.kodi.isNormalUser = true;

    services.cage = {
      enable = true;
      # user = "kodi";
      program = "${lib.getExe waydroid} show-full-ui";
    };
  };
}
