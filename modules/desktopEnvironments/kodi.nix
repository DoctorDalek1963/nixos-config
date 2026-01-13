{
  pkgs,
  lib,
  config,
  ...
}:
let
  kodi = pkgs.kodi-wayland.withPackages (p: with p; [ jellyfin ]);
in
{
  config = lib.mkIf config.setup.desktopEnvironments.kodi.enable {
    users.extraUsers.kodi.isNormalUser = true;

    services.cage = {
      enable = true;
      user = "kodi";
      program = "${kodi}/bin/kodi-standalone";
    };
  };
}
