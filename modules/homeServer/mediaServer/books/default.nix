{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  imports = [./calibre.nix ./readarr.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable && cfgMs.books) {
    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}/torrents/downloads/books
      chown -R transmission:media ${cfgMs.mediaRoot}/torrents/downloads/books
    '';
  };
}
