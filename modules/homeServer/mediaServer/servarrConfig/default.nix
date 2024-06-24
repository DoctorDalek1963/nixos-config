{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  allServarrServices = [
    "add-servarr-root-folders.service"
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
    ./rootFolders.nix
    ./setDateFormats.nix
  ];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    systemd.services.servarr-config = {
      requires = allServarrServices;
      after = allServarrServices;

      description = "Finish setting up servarr configs";

      serviceConfig = {
        Type = "simple";
        ExecStart = let
          mkChown = service: file: "chown ${service}:media ${file}";
          optChown = cond: service: file:
            if cond
            then mkChown service file
            else "";
        in "${pkgs.writeShellScript "finish-servarr-configs" ''
          ${mkChown "prowlarr" "/var/lib/prowlarr/config.xml"}
          ${optChown cfgMs.books "readarr" "${config.services.readarr.dataDir}/config.xml"}
          ${optChown cfgMs.music "lidarr" "${config.services.lidarr.dataDir}/config.xml"}
          ${optChown cfgMs.movies "radarr" "${config.services.radarr.dataDir}/config.xml"}
          ${optChown cfgMs.telly "sonarr" "${config.services.sonarr.dataDir}/config.xml"}
          ${optChown (cfgMs.movies || cfgMs.telly) "bazarr" "/var/lib/bazarr/config/config.yaml"}
        ''}";
      };
    };
  };
}
