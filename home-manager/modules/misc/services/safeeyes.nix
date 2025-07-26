{
  pkgs,
  lib,
  config,
  ...
}:
let
  safeeyes-config-json = (pkgs.formats.json { }).generate "safeeyes-config.json" {
    allow_postpone = true;
    postpone_duration = 1;
    plugins = [
      {
        id = "donotdisturb";
        enabled = false;
      }
    ]
    ++ (map
      (name: {
        id = name;
        enabled = true;
      })
      [
        "audiblealert"
        "healthstats"
        "mediacontrol"
        "notification"
        "screensaver"
        "smartpause"
        "trayicon"
      ]
    );
  };

  path = "${config.xdg.configHome}/safeeyes/safeeyes.json";

  set-safeeyes-config = pkgs.writeShellScript "set-safeeyes-config.sh" ''
    if [ -f "${path}" ]; then
        # Merge declarative config with existing config
        TMP_PATH="$(${pkgs.mktemp}/bin/mktemp)"
        mv "${path}" "$TMP_PATH"
        ${pkgs.jq}/bin/jq --slurp '.[0] * .[1]' "$TMP_PATH" "${safeeyes-config-json}" > "${path}"
    else
        # No existing config, so just copy the declarative config into place
        cp "${safeeyes-config-json}" "${path}"
    fi
  '';
in
{
  config = lib.mkIf config.setup.misc.services.safeeyes {
    services.safeeyes.enable = true;

    home.activation.setSafeeyesConfig = lib.hm.dag.entryAfter [
      "writeBoundary"
    ] "$DRY_RUN_CMD ${set-safeeyes-config}";
    setup.impermanence.keepDirs = ".config/safeeyes";
  };
}
