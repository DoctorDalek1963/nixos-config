{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  audiobookshelf = pkgs.callPackage ./package.nix { };
in
{
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.books) {
    assertions = [
      {
        assertion = audiobookshelf.version == pkgs.audiobookshelf.version;
        message = "You need to update your slightly modified audiobookshelf package (remember to patch twice)";
      }
    ];

    setup = {
      impermanence.keepDirs = [ "/var/lib/audiobookshelf" ];
      backup.paths = [
        "/var/lib/audiobookshelf/config/absdatabase.sqlite"
        "/var/lib/audiobookshelf/metadata"
        "${cfgMs.mediaRoot}/audiobookshelf/big-finish"
      ];

      homeServer.mediaServer.directoryMap.audiobookshelf = [
        "${cfgMs.mediaRoot}/audiobookshelf"
      ];
    };

    services.audiobookshelf = {
      enable = true;
      group = "media";
      port = cfg.ports.mediaServer.audiobookshelf;

      package = audiobookshelf;
    };
  };
}
