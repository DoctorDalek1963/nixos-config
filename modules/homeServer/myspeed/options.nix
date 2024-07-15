{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.services.myspeed;
in {
  options = {
    services.myspeed = {
      enable = mkEnableOption "MySpeed, an analysis tool for internet speed tests.";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/myspeed";
        description = "The directory where MySpeed stores its files.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ./myspeedPackage.nix {};
        description = "The myspeed package to use.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for MySpeed.
        '';
      };

      user = mkOption {
        type = types.str;
        default = "myspeed";
        description = ''
          User account under which MySpeed runs.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "myspeed";
        description = ''
          Group under which MySpeed runs.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-myspeed".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0755";
    };

    systemd.services.myspeed = {
      description = "MySpeed";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];

      environment.NODE_ENV = "production";

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStartPre = [
          "${pkgs.writeShellScript "myspeed-server-pre-start" ''
            if [ ! -d "${cfg.dataDir}/bin" ]; then
                chmod -R u+w "${cfg.dataDir}"
                cp -rv -t "${cfg.dataDir}" \
                    "${cfg.package}/lib/node_modules/myspeed/build" \
                    "${cfg.package}/lib/node_modules/myspeed/node_modules" \
                    "${cfg.package}/lib/node_modules/myspeed/package.json" \
                    "${cfg.package}/lib/node_modules/myspeed/server"
            fi
          ''}"
        ];
        ExecStart = "${pkgs.writeShellScript "myspeed-server" ''
          cd "${cfg.dataDir}"
          ${pkgs.nodejs}/bin/node server
        ''}";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [8282];
    };

    users.users = mkIf (cfg.user == "myspeed") {
      myspeed = {
        description = "MySpeed service";
        home = cfg.dataDir;
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "myspeed") {
      myspeed = {};
    };
  };
}
