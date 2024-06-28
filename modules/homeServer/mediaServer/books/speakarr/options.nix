# These options were lightly adapted from /nixos/modules/services/misc/readarr.nix in nixpkgs.
{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption mkEnableOption mkIf types;
  cfg = config.services.speakarr;
in {
  options = {
    services.speakarr = {
      enable = mkEnableOption "Speakarr, a Usenet/BitTorrent audiobook downloader (Readarr fork)";

      dataDir = mkOption {
        type = types.str;
        default = "/var/lib/speakarr/";
        description = "The directory where Speakarr stores its data files.";
      };

      # TODO: Create package for Speakarr, where we take Readarr, rename it
      # everywhere, change the default port, and change the colourscheme
      package = mkOption {
        type = types.package;
        default = pkgs.readarr; # pkgs.callPackage ./speakarrPackage {};
        description = "The speakarr package to use.";
      };

      openFirewall = mkOption {
        type = types.bool;
        default = false;
        description = ''
          Open ports in the firewall for Speakarr
        '';
      };

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

      serviceConfig = {
        Type = "simple";
        User = cfg.user;
        Group = cfg.group;
        ExecStart = "${cfg.package}/bin/Readarr -nobrowser -data='${cfg.dataDir}'";
        Restart = "on-failure";
      };
    };

    networking.firewall = mkIf cfg.openFirewall {
      allowedTCPPorts = [8282];
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
