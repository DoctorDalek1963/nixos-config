{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.fileflows;

  inherit (lib) mkOption types;

  server-fhs = pkgs.buildFHSEnv {
    name = "fileflows-server-fhs";
    pname = "server"; # Script name
    inherit (cfg.package) version;

    targetPkgs = _pkgs: [cfg.package] ++ cfg.extraPkgs;
    runScript = "server";
  };

  node-fhs = pkgs.buildFHSEnv {
    name = "fileflows-node-fhs";
    pname = "node"; # Script name
    inherit (cfg.package) version;

    targetPkgs = _pkgs: [cfg.package] ++ cfg.extraPkgs;
    runScript = "node";
  };
in {
  options.services.fileflows = {
    package = mkOption {
      type = types.package;
      default = pkgs.callPackage ./package.nix {};
      description = ''
        The package to use for FileFlows.

        Must provide /bin/server and /bin/node (if services are enabled). The services handle the FHS logic to provide extraPkgs, so that should not be done here.
      '';
    };

    extraPkgs = mkOption {
      type = types.listOf types.package;
      default = [];
      example = lib.literalMD "with pkgs; [jellyfin-ffmpeg]";
      description = ''
        Extra packages to install for FileFlows.

        These will be provided in an FHS environment in /usr/bin so that FileFlows can reference them easily and the links will continue to work even after updates.
      '';
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
    };
  };

  config = lib.mkMerge [
    (lib.mkIf cfg.server.enable {
      systemd = {
        tmpfiles.settings.fileflowsDirs."${cfg.server.baseDir}".d = {
          mode = "700";
          inherit (cfg.server) user group;
        };

        services.fileflows-server = {
          description = "FileFlows server with integrated node";
          script = "${server-fhs}/bin/server --no-gui --systemd-service";

          startLimitIntervalSec = 200;
          startLimitBurst = 3;

          requires = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          environment.FILEFLOWS_SERVER_BASE_DIR = cfg.server.baseDir;

          serviceConfig = {
            Type = "simple";

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
        allowedTCPPorts = [19200];
      };
    })

    (lib.mkIf cfg.node.enable {
      systemd = {
        tmpfiles.settings.fileflowsDirs."${cfg.node.baseDir}".d = {
          mode = "700";
          inherit (cfg) user group;
        };

        services.fileflows-node = {
          description = "FileFlows node";
          script = "${node-fhs}/bin/node --no-gui --systemd-service";

          startLimitIntervalSec = 200;
          startLimitBurst = 3;

          requires = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          environment.FILEFLOWS_NODE_BASE_DIR = cfg.node.baseDir;

          serviceConfig = {
            Type = "simple";

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
