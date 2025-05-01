{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;
in {
  imports = [./options.nix];

  config = lib.mkIf (cfg.enable && cfgMs.enable) {
    services.fileflows = {
      extraPkgs = [pkgs.jellyfin-ffmpeg];

      server = {
        enable = true;
        group = "media";
      };

      node = {
        enable = true;
        group = "media";
        serverUrl = "http://localhost:${toString cfg.ports.mediaServer.fileflows}";
      };
    };

    setup = {
      backup = {
        paths = [config.services.fileflows.server.baseDir];
        exclude = ["${config.services.fileflows.server.baseDir}/Temp"];
      };

      impermanence.keepDirs = [
        {
          directory = config.services.fileflows.server.baseDir;
          inherit (config.services.fileflows.server) user group;
          mode = "750";
        }
        {
          directory = config.services.fileflows.node.baseDir;
          inherit (config.services.fileflows.node) user group;
          mode = "750";
        }
      ];
    };
  };
}
