{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  allServarrServices = [
    "add-user-to-servarr-apps.service"
    "set-servarr-config-files.service"
  ];
in {
  # TODO: Add Transmission as download client to all servarr apps.
  # TODO: Add all servarr apps to prowlarr (maybe manage tags here as well)
  # TODO: Set date formats for all servarr apps
  imports = [./addUser.nix ./configFiles.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.targets.servarr-config = {
      requires = allServarrServices;
      after = allServarrServices;
    };
  };
}
