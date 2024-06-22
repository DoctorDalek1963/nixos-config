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
    "set-servarr-date-formats.service"
  ];
in {
  # TODO: Add all servarr apps to prowlarr (maybe manage tags here as well)
  imports = [./addTransmission.nix ./addUser.nix ./configFiles.nix ./setDateFormats.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.targets.servarr-config = {
      requires = allServarrServices;
      after = allServarrServices;
    };
  };
}
