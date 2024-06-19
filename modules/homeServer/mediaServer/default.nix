{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  imports = [./books ./music ./prowlarr.nix ./servarrConfigs.nix ./transmission.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    users.groups.media = {};

    boot.postBootCommands = ''
      mkdir -p ${cfgMs.mediaRoot}
      chown root:media ${cfgMs.mediaRoot}
      chmod -R a+r ${cfgMs.mediaRoot}
    '';
  };
}
