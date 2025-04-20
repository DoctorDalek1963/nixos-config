{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.homeServer;
  cfgMs = cfg.mediaServer;

  transmission-ntfy = pkgs.callPackage ./package.nix {};
  working-dir = "/var/lib/transmission-ntfy";

  user = "ntfy-sh";
  group = "ntfy-sh";
in {
  config = lib.mkIf (cfg.enable && cfgMs.enable && cfg.ntfy.enable) {
    setup.impermanence.keepDirs = [
      {
        directory = working-dir;
        inherit user group;
        mode = "0755";
      }
    ];

    systemd = {
      services = {
        transmission-ntfy = {
          description = "Send notifications about Transmission with Ntfy";

          after = ["transmission.service" "ntfy-sh.service"];
          requires = ["transmission.service" "ntfy-sh.service"];

          wantedBy = ["multi-user.target"];

          environment = rec {
            TURL =
              "http://192.168.${toString cfgMs.transmission.thirdOctet}.2"
              + ":${toString cfg.ports.mediaServer.transmission}"
              + "/transmission/rpc/";

            NURL = "http://localhost:${toString cfg.ports.ntfy.http}/";
            NUSER = "transmission-ntfy";
            NPWD = "password";

            RUST_BACKTRACE = "full";
            RUST_LOG = "info";

            NTFY_PASSWORD = NPWD; # For ExecStartPre
          };

          serviceConfig = {
            Type = "simple";
            RestartSec = "60s";
            Restart = "on-failure";

            User = user;
            Group = group;

            ExecStartPre = ["${pkgs.ntfy-sh}/bin/ntfy user add --ignore-exists --role=user transmission-ntfy"];
            ExecStart = "${transmission-ntfy}/bin/transmission_api_client";
            WorkingDirectory = working-dir;
          };
        };
      };
    };
  };
}
