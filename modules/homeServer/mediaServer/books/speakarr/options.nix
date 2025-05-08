# These options were lightly adapted from /nixos/modules/services/misc/readarr.nix in nixpkgs.
{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.services.speakarr;

  servarr = import (modulesPath + "/services/misc/servarr/settings-options.nix") {inherit lib pkgs;};
in {
  options = {
    services.speakarr = {
      enable = mkEnableOption "Speakarr, a Usenet/BitTorrent audiobook downloader (Readarr fork)";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/speakarr";
        description = "The directory where Speakarr stores its data files.";
      };

      package = mkOption {
        type = types.package;
        default = pkgs.callPackage ./speakarrPackage {};
        description = "The speakarr package to use.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for Speakarr
        '';
      };

      settings = servarr.mkServarrSettingsOptions "speakarr" 8282;

      environmentFiles = servarr.mkServarrEnvironmentFiles "speakarr";

      user = mkOption {
        type = types.str;
        default = "speakarr";
        description = ''
          User account under which Speakarr runs.
        '';
      };

      group = mkOption {
        type = types.str;
        default = "speakarr";
        description = ''
          Group under which Speakarr runs.
        '';
      };
    };
  };

  config = mkIf cfg.enable {
    systemd.tmpfiles.settings."10-speakarr".${cfg.dataDir}.d = {
      inherit (cfg) user group;
      mode = "0700";
    };

    systemd.services.speakarr = {
      description = "Speakarr";
      after = ["network.target"];
      wantedBy = ["multi-user.target"];
      environment = servarr.mkServarrSettingsEnvVars "SPEAKARR" cfg.settings;

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/Speakarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [cfg.settings.server.port];
    };

    users.users = mkIf (cfg.user == "speakarr") {
      speakarr = {
        description = "Speakarr service";
        home = cfg.dataDir;
        inherit (cfg) group;
        isSystemUser = true;
      };
    };

    users.groups = mkIf (cfg.group == "speakarr") {
      speakarr = {};
    };
  };
}
