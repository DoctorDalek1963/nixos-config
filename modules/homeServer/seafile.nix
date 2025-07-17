{
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgSf = config.setup.homeServer.seafile;
in {
  config = lib.mkIf (cfg.enable && cfgSf.enable) {
    # setup = {
    #   impermanence.keepDirs = [
    #     "/var/lib/seafile"
    #   ];
    #   backup.paths = [config.services.seafile.dataDir];
    # };

    users.groups.seafile = {
      members = lib.optional (cfg.manager != null) cfg.manager;
    };

    # TODO: Mirror data. Seafile stores files withh checksums a bit like git,
    # so I'd like to also store files normally alongside seafile and sync them
    # regularly. But do I actually need that or am I happy to just keep the
    # seafile format and back that up directly?

    services = {
      seafile = {
        enable = true;
        dataDir = cfg.cloudRoot; # TODO: Is this what I want?

        gc = {
          enable = true;
          dates = ["Tuesday 02:30:00"];
        };

        seafileSettings = {
          database.type = "sqlite";
          history.keep_days = 30;

          fileserver.port = cfg.ports.seafile.fileserver;
        };

        seahubAddress = "127.0.0.1:${toString cfg.ports.seafile.seahub}";
        seahubExtraConf = {};
      };
    };
  };
}
