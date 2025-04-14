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
    users.groups.media = {};

    systemd.tmpfiles.rules = ["d ${cfgMs.mediaRoot} 0775 root media - -"];
  };
}
