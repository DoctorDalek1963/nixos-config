{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.desktopEnvironments.cinnamon;
in {
  config = lib.mkIf cfg.enable {
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
            "menu-label": {"value": ""},
          }
        '';

      shell-script = pkgs.writeShellScript "insert-cinnamon-menu-icon" ''
        mkdir -p "${jsonDir}"
        ${pkgs.jq}/bin/jq --slurp '.[0] * .[1]' "${jsonDir}/0.json" "${iconJsonFile}"
      '';
    in
      lib.hm.dag.entryAfter ["writeBoundary"] ''$DRY_RUN_CMD ${shell-script}'';
  };
}
