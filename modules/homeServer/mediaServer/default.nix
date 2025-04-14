{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  imports = [./torrenting ./servarrConfig ./books ./music ./video ./prowlarr.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    # TODO (25.05): Change all servarr stuff to use the new declarative config style

    users.groups.media = {};

    systemd.tmpfiles.rules = ["d ${cfgMs.mediaRoot} 0775 root media - -"];
  };
}
