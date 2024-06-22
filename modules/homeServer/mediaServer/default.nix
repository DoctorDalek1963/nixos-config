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

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}
      chown root:media ${cfgMs.mediaRoot}
      chmod -R a+r ${cfgMs.mediaRoot}
      chmod -R g+w ${cfgMs.mediaRoot}
    '';
  };
}
