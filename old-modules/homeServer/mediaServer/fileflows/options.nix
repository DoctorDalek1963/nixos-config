{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.services.fileflows;

  inherit (lib) mkOption types;

  mkSystemdService =
    {
      description,
      script,
      environment,
      user,
      group,
      extra ? { },
    }:
    lib.attrsets.recursiveUpdate {
      inherit description script environment;

      requires = [ "network-online.target" ];
      after = [ "network-online.target" ];
      wantedBy = [ "multi-user.target" ];

      serviceConfig = {
        Type = "simple";
        User = user;
        Group = group;

        Restart = "always";
        RestartSec = 10;

        ReadOnlyPaths = [ cfg.binDir ];
        BindReadOnlyPaths = [ "${cfg.binDir}:/bin" ];

        # Hardening
        IPAddressAllow = "127.0.0.1";
        RestrictAddressFamilies = [
          "AF_UNIX"
          "AF_NETLINK"
          "AF_INET"
          "AF_INET6"
        ];

        LockPersonality = true;
        NoNewPrivileges = true;

        PrivateTmp = true;
        PrivateUsers = "self";

        ProtectClock = true;
        ProtectControlGroups = true;
        ProtectHome = true;
        ProtectKernelLogs = true;
        ProtectKernelModules = true;
        ProtectKernelTunables = true;
        ProtectProc = "invisible";
        ProtectSystem = "strict";

        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        MemoryDenyWriteExecute = false;

        AmbientCapabilities = "";
        CapabilityBoundingSet = "";
        SystemCallFilter = [ "@system-service" ];
      };
    } extra;
in
{
  options.services.fileflows = {
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./package.nix { };
    };

    extraPkgs = mkOption {
      type = types.listOf types.package;
      default = [ ];
      example = lib.literalMD "with pkgs; [jellyfin-ffmpeg]";
      description = "Extra packages to install in `config.services.fileflows.binDir`.";
    };

    binDir = mkOption {
      type = types.nonEmptyStr;
      default = "/var/lib/fileflows/bin";
      description = "The directory where the extraPkgs will be symlinked.";
    };

    libraryPaths = mkOption {
      type = types.listOf types.nonEmptyStr;
      description = "List of paths containing file libraries. These libraries contain the files you want to flow.";
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
      systemd.tmpfiles.settings.fileflowsDirs."${cfg.binDir}"."L+".argument = "${
        pkgs.symlinkJoin {
          name = "fileflows-extra-pkgs";
          paths = cfg.extraPkgs;
        }
      }/bin";
    })

    (lib.mkIf cfg.server.enable {
      systemd = {
        tmpfiles.settings.fileflowsDirs."${cfg.server.baseDir}".d = {
          mode = "700";
          inherit (cfg.server) user group;
        };

        services.fileflows-server = mkSystemdService {
          description = "FileFlows server with integrated node";
          script = "${cfg.package}/bin/server --no-gui --systemd-service --urls=http://[::]:${toString cfg.server.port}";

          environment.FILEFLOWS_SERVER_BASE_DIR = cfg.server.baseDir;

          inherit (cfg.server) user group;

          extra.serviceConfig = {
            TasksMax = 1000;

            ReadWritePaths = [ cfg.server.baseDir ] ++ cfg.libraryPaths;
          };
        };
      };

      users.users.fileflows = lib.mkIf (cfg.server.user == "fileflows") {
        isSystemUser = true;
        inherit (cfg.server) group;
      };

      networking.firewall = lib.mkIf cfg.server.openFirewall {
        allowedTCPPorts = [ cfg.server.port ];
      };
    })

    (lib.mkIf cfg.node.enable {
      systemd = {
        tmpfiles.settings.fileflowsDirs."${cfg.node.baseDir}".d = {
          mode = "700";
          inherit (cfg.node) user group;
        };

        services.fileflows-node = mkSystemdService {
          description = "FileFlows node";
          script = "${cfg.package}/bin/node --no-gui --systemd-service --server ${cfg.node.serverUrl}";

          environment.FILEFLOWS_NODE_BASE_DIR = cfg.node.baseDir;

          inherit (cfg.node) user group;

          extra = {
            startLimitIntervalSec = 200;
            startLimitBurst = 3;

            serviceConfig = {
              ReadWritePaths = [ cfg.node.baseDir ] ++ cfg.libraryPaths;
            };
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
