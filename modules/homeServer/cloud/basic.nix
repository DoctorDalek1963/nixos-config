{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;
  cfgCb = config.setup.homeServer.cloud.basic;
in
{
  config = lib.mkIf (cfg.enable && cfgCb.enable) {
    setup.backup.paths = [ cfgCb.cloudRoot ];

    systemd.tmpfiles.settings.cloudBasic."${cfgCb.cloudRoot}".d = {
      user = cfg.manager;
      inherit (config.users.users."${cfg.manager}") group;
      mode = "755";
    };
  };
}
