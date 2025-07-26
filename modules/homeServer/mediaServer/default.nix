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
  imports = [
    ./torrenting
    ./servarrConfig
    ./books
    ./music
    ./video
    ./fileflows
    ./porn

    ./directoryMap.nix
    ./prowlarr.nix
  ];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    users.groups.media = {
      members = lib.optional (cfg.manager != null) cfg.manager;
    };

    setup.backup.paths = [ cfgMs.mediaRoot ];
  };
}
