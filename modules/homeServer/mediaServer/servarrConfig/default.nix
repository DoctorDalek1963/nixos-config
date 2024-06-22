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
    "populate-prowlarr.service"
    "set-servarr-config-files.service"
    "set-servarr-date-formats.service"
  ];
in {
  imports = [
    ./addTransmission.nix
    ./addUser.nix
    ./configFiles.nix
    ./populateProwlarr.nix
    ./setDateFormats.nix
  ];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.targets.servarr-config = {
      requires = allServarrServices;
      after = allServarrServices;
    };
  };
}
