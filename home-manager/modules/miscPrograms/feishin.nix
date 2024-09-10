{
  pkgs,
  lib,
  config,
  ...
}: let
  feishin-config-json = (pkgs.formats.json {}).generate "feishin-config.json" {
    disable_auto_updates = true;
    mpv_path = "${pkgs.mpv}/bin/mpv";
    theme = "system";
    window_minimize_to_tray = true;
    window_exit_to_tray = true;
  };

  path = "${config.xdg.configHome}/feishin/config.json";

  set-feishin-config = pkgs.writeShellScript "set-feishin-config.sh" ''
    if [ -f "${path}" ]; then
        # Merge declarative config with existing config
        TMP_PATH="$(${pkgs.mktemp}/bin/mktemp)"
        mv "${path}" "$TMP_PATH"
        ${pkgs.jq}/bin/jq --slurp '.[0] * .[1]' "$TMP_PATH" "${feishin-config-json}" > "${path}"
    else
        # No existing config, so just copy the declarative config into place
        cp "${feishin-config-json}" "${path}"
    fi
  '';
in {
  config = lib.mkIf config.setup.miscPrograms.feishin {
    home = {
      packages = [pkgs.feishin];

      activation.setFeishinConfig =
        lib.hm.dag.entryAfter ["writeBoundary"]
        "$DRY_RUN_CMD ${set-feishin-config}";
    };

    setup.impermanence.keepDirs = [".config/feishin"];
  };
}
