{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  allServarrServices = [
    "add-transmission-to-servarr-apps.service"
    "add-user-to-servarr-apps.service"
    "set-servarr-config-files.service"
  ];
in {
  # TODO: Add all servarr apps to prowlarr (maybe manage tags here as well)
  # TODO: Set date formats for all servarr apps
  imports = [./addTransmission.nix ./addUser.nix ./configFiles.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.targets.servarr-config = {
      requires = allServarrServices;
      after = allServarrServices;
    };
  };
}
