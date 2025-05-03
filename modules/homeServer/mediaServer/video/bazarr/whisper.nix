{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  cacheDir = "/var/cache/whisper-asr";
  cacheDirPerms = {
    user = "bazarr";
    group = "media";
    mode = "755";
  };
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && (cfgMs.movies || cfgMs.telly)) {
    setup.impermanence.keepDirs = [
      ({directory = cacheDir;} // cacheDirPerms)
    ];

    systemd.tmpfiles.settings.whisperAsr."${cacheDir}".d = cacheDirPerms;

    # TODO: Replace container with native nix package, probably external flake with poetry2nix?
  };
}
