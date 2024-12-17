{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup.desktopEnvironments.cinnamon;
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.cinnamon.enable {
    home.activation.insertCinnamonMenuIcon = let
      jsonDir = "${config.xdg.configHome}/cinnamon/spices/menu@cinnamon.org";
      menuIcon =
        if cfg.menuIcon != null
        then cfg.menuIcon
        else "cinnamon-symbolic";
      iconJsonFile =
        pkgs.writeText "icon.json"
        # json
        ''
          {
            "menu-custom": {"value": true},
            "menu-icon": {"value": "${menuIcon}"},
            "menu-icon-size": {"value": 32},
            "menu-label": {"value": ""}
          }
        '';

      shell-script = pkgs.writeShellScript "insert-cinnamon-menu-icon" ''
        mkdir -p "${jsonDir}"
        ${pkgs.jq}/bin/jq --slurp '.[0] * .[1]' "${jsonDir}/0.json" "${iconJsonFile}" > /tmp/insert-cinnamon-menu-icon.json
        mv /tmp/insert-cinnamon-menu-icon.json "${jsonDir}/0.json"
      '';
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''$DRY_RUN_CMD ${shell-script}'';
  };
}
