{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    setup = {
      impermanence.keepDirs = [ "/var/lib/private/seerr" ];
      backup = {
        paths = [ "/var/lib/private/seerr" ];
        exclude = [ "/var/lib/private/seerr/logs" ];
      };
    };

    services.seerr = {
      enable = true;
      # group = "media";
      port = cfg.ports.mediaServer.seerr;
    };
  };
}
