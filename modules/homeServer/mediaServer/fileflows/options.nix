{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.fileflows;

  inherit (lib) mkOption types;
in {
  options.services.fileflows = {
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./package.nix {};
    };

    extraPkgs = mkOption {
      type = types.listOf types.package;
      default = [];
      example = lib.literalMD "with pkgs; [jellyfin-ffmpeg]";
      description = "Extra packages to install in `config.services.fileflows.binDir`.";
    };

    binDir = mkOption {
      type = types.nonEmptyStr;
      default = "/var/lib/fileflows/bin";
      description = "The directory where the extraPkgs will be symlinked.";
    };

    server = {
      enable = lib.mkEnableOption "FileFlows server";

      user = mkOption {
        type = types.nonEmptyStr;
        default = "fileflows";
        description = "User account under which the FileFlows server runs.";
      };

      group = mkOption {
        type = types.nonEmptyStr;
        default = "fileflows";
        description = "Group under which the FileFlows server runs.";
      };

      port = mkOption {
        type = types.port;
        default = 19200;
        description = "The port to run the FileFlows server on.";
      };

      baseDir = mkOption {
        type = types.nonEmptyStr;
        default = "/var/lib/fileflows/server";
        description = "The directory where the FileFlows server stores its config.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = "Whether to open the port for FileFlows in the firewall.";
      };
    };

    node = {
      enable = lib.mkEnableOption "FileFlows standalone node";

      user = mkOption {
        type = types.nonEmptyStr;
        default = "fileflows";
        description = "User account under which the FileFlows node runs.";
      };

      group = mkOption {
        type = types.nonEmptyStr;
        default = "fileflows";
        description = "Group under which the FileFlows node runs.";
      };

      baseDir = mkOption {
        type = types.nonEmptyStr;
        default = "/var/lib/fileflows/node";
        description = "The directory where the FileFlows node stores its config.";
      };

      serverUrl = mkOption {
        type = types.nonEmptyStr;
        description = "The URL of the FileFlows server to connect to.";
      };
    };
  };

  config = lib.mkMerge [
    (lib.mkIf (cfg.server.enable || cfg.node.enable) {
      systemd.tmpfiles.settings.fileflowsDirs."${cfg.binDir}"."L+".argument = "${pkgs.symlinkJoin {
        name = "fileflows-extra-pkgs";
        paths = cfg.extraPkgs;
      }}/bin";
    })

    (lib.mkIf cfg.server.enable {
      systemd = {
        tmpfiles.settings.fileflowsDirs."${cfg.server.baseDir}".d = {
          mode = "700";
          inherit (cfg.server) user group;
        };

        services.fileflows-server = {
          description = "FileFlows server with integrated node";
          script = "${cfg.package}/bin/server --no-gui --systemd-service --urls=http://[::]:${toString cfg.server.port}";

          startLimitIntervalSec = 200;
          startLimitBurst = 3;

          requires = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          environment.FILEFLOWS_SERVER_BASE_DIR = cfg.server.baseDir;

          serviceConfig = {
            Type = "simple";
            User = cfg.server.user;
            Group = cfg.server.group;

            Restart = "always";
            RestartSec = 10;
          };
        };
      };

      users.users.fileflows = lib.mkIf (cfg.server.user == "fileflows") {
        isSystemUser = true;
        inherit (cfg.server) group;
      };

      networking.firewall = lib.mkIf cfg.server.openFirewall {
        allowedTCPPorts = [cfg.server.port];
      };
    })

    (lib.mkIf cfg.node.enable {
      systemd = {
        tmpfiles.settings.fileflowsDirs."${cfg.node.baseDir}".d = {
          mode = "700";
          inherit (cfg.node) user group;
        };

        services.fileflows-node = {
          description = "FileFlows node";
          script = "${cfg.package}/bin/node --no-gui --systemd-service --server ${cfg.node.serverUrl}";

          startLimitIntervalSec = 200;
          startLimitBurst = 3;

          requires = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          environment.FILEFLOWS_NODE_BASE_DIR = cfg.node.baseDir;

          serviceConfig = {
            Type = "simple";
            User = cfg.node.user;
            Group = cfg.node.group;

            Restart = "always";
            RestartSec = 10;
          };
        };
      };

      users.users.fileflows = lib.mkIf (cfg.node.user == "fileflows") {
        isSystemUser = true;
        inherit (cfg.node) group;
      };
    })
  ];
}
