{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  yq = "${pkgs.yq-go}/bin/yq";

  toTitleCase = string: let
    chars = lib.strings.stringToCharacters string;
    newChars = lib.lists.imap0 (idx: char:
      if idx == 0
      then lib.strings.toUpper char
      else char)
    chars;
  in
    lib.strings.concatStrings newChars;

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
  servarrTemplate = name: {
    Port = cfg.ports.mediaServer."${name}";
    ApiKey = "$HOMEPAGE_VAR_${lib.strings.toUpper name}_KEY";
    AuthenticationMethod = "Basic";
    AuthenticationRequired = "Enabled";
    UrlBase = "${name}";
    InstanceName = "${toTitleCase name}";
  };

  script = pkgs.writeShellScript "set-servarr-configs" (''
      source ${config.sops.secrets."home-server/homepage.env".path}

      ${yq} -i ${shConfExpr (servarrTemplate "prowlarr")} /var/lib/prowlarr/config.xml
    ''
    + (
      lib.strings.concatStringsSep "\n"
      (
        lib.optional cfgMs.music
        "${yq} -i ${shConfExpr (servarrTemplate "lidarr")} ${config.services.lidarr.dataDir}/config.xml"
      )
    ));
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    # Don't forget to tell each servarr systemd service that it requires this
    # service and is ordered after it
    systemd.services.set-servarr-configs = {
      description = "Setup the config.xml files for Servarr apps";

      serviceConfig = {
        Type = "simple";
        ExecStart = "${script}";
      };
    };
  };
}
