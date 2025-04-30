{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.services.fileflows;

  inherit (lib) mkOption types;

  optPrintExtraPkgs =
    lib.optional (builtins.length cfg.extraPkgs > 0) ''echo -e "Extra packages:\n${builtins.concatStringsSep "\\n" (map toString cfg.extraPkgs)}"'';
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
      description = ''
        Extra packages to install in the Nix store.

        These won't affect the server or node directly, but this option guarantees that these packages will be installed, and will print all their paths at the start of the systemd services.
      '';
    };

    server = {
      enable = lib.mkEnableOption "FileFlows server";

      user = mkOption {
        type = types.nonEmptyStr;
        default = "fileflows";
        description = "User account under which the FileFlow server runs.";
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
        description = "User account under which the FileFlow node runs.";
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

  config = lib.mkIf cfg.enable {
    systemd = {
      tmpfiles.settings.fileflowsDirs = {
        "${cfg.server.baseDir}".d = {
          mode = "700";
          inherit (cfg.server) user group;
        };

        "${cfg.node.baseDir}".d = {
          mode = "700";
          inherit (cfg) user group;
          age = "24h";
        };
      };

      services = {
        fileflows-server = {
          description = "FileFlows server with integrated node";
          script = "${cfg.package}/bin/server --no-gui --systemd-service";

          startLimitIntervalSec = 200;
          startLimitBurst = 3;

          requires = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          environment.FILEFLOWS_SERVER_BASE_DIR = cfg.server.baseDir;

          serviceConfig = {
            Type = "simple";

            ExecStartPre = optPrintExtraPkgs;

            Restart = "always";
            RestartSec = 10;
          };
        };

        fileflows-node = {
          description = "FileFlows node";
          script = "${cfg.package}/bin/node --no-gui --systemd-service";

          startLimitIntervalSec = 200;
          startLimitBurst = 3;

          requires = ["network-online.target"];
          after = ["network-online.target"];
          wantedBy = ["multi-user.target"];

          environment.FILEFLOWS_NODE_BASE_DIR = cfg.node.baseDir;

          serviceConfig = {
            Type = "simple";

            ExecStartPre = optPrintExtraPkgs;

            Restart = "always";
            RestartSec = 10;
          };
        };
      };
    };

    users.users.fileflows = lib.mkIf (cfg.server.user == "fileflows" || cfg.node.user == "fileflows") {
      isSystemUser = true;
      inherit (cfg) group;
    };

    networking.firewall = lib.mkIf cfg.openFirewall {
      allowedTCPPorts = [19200];
    };
  };
}
