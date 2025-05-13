{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  yq = "${pkgs.yq-go}/bin/yq";

  # Transform a Nix attribute set into a yq expression to set .Config.<name>
  # for every <name> in the set. This function returns a non-escaped string. It
  # will contain double quotes, so should be properly escaped and wrapped in
  # double quotes to use as a yq expression.
  confExpr = set:
    builtins.concatStringsSep " | " (lib.attrsets.mapAttrsToList
      (name: value: ".Config.${name} = \"${toString value}\"")
      set);

  # This is a wrapper around confExpr which escapes the quotes and wraps the
  # whole thing in another set of quotes so it can be seemlessly dropped into a
  # bash script.
  shConfExpr = set: ''"${lib.strings.escape ["\""] (confExpr set)}"'';

  # Use the name of a servarr app to populate a template of common options. The
  # resulting set should then be passed to shConfExpr.
  # I used to use this for much more before we had services.*arr.settings, but
  # we still need to get the API key from homepage.env, so we keep this.
  servarrTemplate = name: {
    ApiKey = "$HOMEPAGE_VAR_${lib.strings.toUpper name}_KEY";
  };

  mkCommand = yqExpr: dataDir: ''
    mkdir -p ${dataDir}
    touch ${dataDir}/config.xml
    ${yq} -i ${yqExpr} ${dataDir}/config.xml
  '';

  script = pkgs.writeShellScript "set-servarr-config-files" (''
      source ${config.sops.secrets."home-server/homepage.env".path}
    ''
    + (
      lib.strings.concatStringsSep "\n"
      (
        [(mkCommand (shConfExpr (servarrTemplate "prowlarr")) "/var/lib/prowlarr")]
        ++ (
          lib.optional cfgMs.music
          (mkCommand (shConfExpr (servarrTemplate "lidarr")) config.services.lidarr.dataDir)
        )
        ++ (
          lib.optional cfgMs.books
          (mkCommand (shConfExpr (servarrTemplate "readarr")) config.services.readarr.dataDir)
        )
        ++ (
          lib.optional cfgMs.books
          (mkCommand (shConfExpr (servarrTemplate "speakarr")) config.services.speakarr.dataDir)
        )
        ++ (
          lib.optional cfgMs.movies
          (mkCommand (shConfExpr (servarrTemplate "radarr")) config.services.radarr.dataDir)
        )
        ++ (
          lib.optional cfgMs.telly
          (mkCommand (shConfExpr (servarrTemplate "sonarr")) config.services.sonarr.dataDir)
        )
        ++ (
          lib.optional cfgMs.porn
          (mkCommand (shConfExpr (servarrTemplate "whisparr")) config.services.whisparr.dataDir)
        )
        ++ (
          lib.optional (cfgMs.movies || cfgMs.telly)
          (let
            yqExpr = builtins.concatStringsSep " | " [
              ''.auth.apikey = "$HOMEPAGE_VAR_BAZARR_KEY"''
              ''.auth.type = null''
              ''.general.base_url = "/bazarr"''

              ''.general.use_radarr = true''
              ''.radarr.apikey = "$HOMEPAGE_VAR_RADARR_KEY"''
              ''.radarr.base_url = "/radarr"''
              ''.radarr.ip = "localhost"''
              ''.radarr.port = ${toString cfg.ports.mediaServer.radarr}''

              ''.general.use_sonarr = true''
              ''.sonarr.apikey = "$HOMEPAGE_VAR_SONARR_KEY"''
              ''.sonarr.base_url = "/sonarr"''
              ''.sonarr.ip = "localhost"''
              ''.sonarr.port = ${toString cfg.ports.mediaServer.sonarr}''

              ''.opensubtitlescom.username = "$OPENSUBTITLES_USERNAME"''
              ''.opensubtitlescom.password = "$OPENSUBTITLES_PASSWORD"''

              ''.whisper.endpoint = "http://127.0.0.1:9000"''
              ''.whisper.response = 60''
              ''.whisper.timeout = 3600''
            ];
          in ''
            mkdir -p /var/lib/bazarr/config
            touch /var/lib/bazarr/config/config.yaml
            ${yq} -i "${lib.strings.escape ["\""] yqExpr}" /var/lib/bazarr/config/config.yaml
          '')
        )
      )
    ));
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    # Don't forget to tell each servarr systemd service that it requires this
    # service and is ordered after it
    systemd.services.set-servarr-config-files = {
      description = "Setup the config.xml files for Servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${script}";
      };
    };
  };
}
