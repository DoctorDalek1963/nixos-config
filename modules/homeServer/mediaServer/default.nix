{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  imports = [
    ./torrenting
    ./servarrConfig
    ./books
    ./music
    ./video
    ./fileflows

    ./prowlarr.nix
  ];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    # TODO (25.05): Change all servarr stuff to use the new declarative config style

    users.groups.media = {};

    systemd.tmpfiles.settings.mediaRoot."${cfgMs.mediaRoot}" = {
      d = {
        user = "root";
        group = "media";
        mode = "775";
      };

      # Set ACL to make new files group-readable by media by default
      A.argument = "u::rw,g:media:rw,o::r";
    };

    setup.backup.paths = [cfgMs.mediaRoot];
  };
}
