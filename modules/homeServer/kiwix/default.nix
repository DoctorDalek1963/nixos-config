{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.homeServer;

  download-zim = pkgs.stdenv.mkDerivation {
    name = "download-zim-files-for-kiwix";
    propagatedBuildInputs = [ (pkgs.python3.withPackages (p: [ p.requests ])) ];
    dontUnpack = true;
    installPhase = "install -Dm755 ${./download.py} $out/bin/download.py";
  };

  kiwix-serve = pkgs.writeShellApplication {
    name = "kiwix-serve";
    runtimeInputs = [ pkgs.kiwix-tools ];

    text = ''
      cmd=(
        kiwix-serve
        --port=${toString cfg.ports.kiwix}
        --urlRootLocation=/wiki
      )

      for f in /var/lib/kiwix/zim/*; do
        cmd+=("$f")
      done

      exec "''${cmd[@]}"
    '';
  };
in
{
  config = lib.mkIf (cfg.enable && cfg.kiwix.enable) {
    services.nginx.virtualHosts."${cfg.domainName}".locations = {
      "/wiki" = {
        proxyPass = "http://localhost:${toString cfg.ports.kiwix}/wiki";
        extraConfig = ''
          proxy_redirect off;
          proxy_http_version 1.1;
          proxy_set_header Upgrade $http_upgrade;
          proxy_set_header Connection $http_connection;
        '';
      };
    };

    users = {
      users.kiwix = {
        isSystemUser = true;
        group = "kiwix";
      };
      groups.kiwix.members = [ cfg.manager ];
    };

    setup.impermanence.keepDirs = [
      {
        directory = "/var/lib/kiwix/zim";
        user = "kiwix";
        group = "kiwix";
        mode = "u=rwx,g=rwx,o=";
      }
    ];

    systemd = {
      tmpfiles.settings.kiwix."/var/lib/kiwix/zim".d = {
        user = "kiwix";
        group = "kiwix";
        mode = "770";
      };

      services = {
        kiwix-serve = {
          wantedBy = [ "multi-user.target" ];
          requires = [ "network-online.target" ];
          after = [ "network-online.target" ];

          serviceConfig = {
            ExecStart = [ "${kiwix-serve}/bin/kiwix-serve" ];

            Type = "simple";
            User = "kiwix";
            Group = "kiwix";

            Restart = "on-failure";
            RestartSec = "5s";

            # Hardening
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
            ReadOnlyPaths = [ "/var/lib/kiwix/zim" ];

            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            MemoryDenyWriteExecute = true;

            AmbientCapabilities = [ ];
            CapabilityBoundingSet = [ ];
            SystemCallFilter = [ "@system-service" ];
          };
        };

        # TODO: What about deleting old files after we download a newer version?
        kiwix-zim-files-download = {
          serviceConfig = {
            ExecStart = [
              (lib.concatStringsSep " " (
                [
                  "${download-zim}/bin/download.py"
                  "/var/lib/kiwix/zim"
                ]
                ++ cfg.kiwix.zimFilePrefixes
              ))
            ];
            ExecStopPost = [ "+/run/current-system/sw/bin/systemctl try-restart kiwix-serve.service" ];

            Type = "oneshot";
            User = "kiwix";
            Group = "kiwix";

            Restart = "on-failure";
            RestartSec = "5s";

            # Hardening
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
            ReadWritePaths = [ "/var/lib/kiwix/zim" ];

            RestrictRealtime = true;
            RestrictSUIDSGID = true;
            SystemCallArchitectures = "native";
            MemoryDenyWriteExecute = true;

            AmbientCapabilities = [ ];
            CapabilityBoundingSet = [ ];
            SystemCallFilter = [ "@system-service" ];
          };
        };
      };

      timers.kiwix-zim-files-download = {
        timerConfig = {
          OnCalendar = "*-*-1 04:00:00"; # 4 am on the first of every month
          Unit = "kiwix-zim-files-download.service";
        };

        wantedBy = [ "timers.target" ];
      };
    };
  };
}
