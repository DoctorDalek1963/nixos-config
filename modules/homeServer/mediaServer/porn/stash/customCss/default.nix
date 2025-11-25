{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
  inherit (builtins) readFile;
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.porn) {
    systemd.tmpfiles.settings.stash = {
      "${config.services.stash.dataDir}/custom.css".C = {
        user = "stash";
        group = "media";
        mode = "755";
        argument = toString (
          pkgs.writeTextFile {
            name = "stash-custom.css";
            text = ''
              ${readFile ./ratingBanner.css}
            '';
          }
        );
      };
    };
  };
}
