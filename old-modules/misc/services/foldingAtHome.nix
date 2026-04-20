{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.misc.services.foldingAtHome;
in
{
  config = lib.mkIf cfg.enable {
    sops.secrets."foldingAtHome/config.xml".mode = "0444";

    setup.impermanence.keepDirs = [ "/var/lib/foldingathome" ];

    services.foldingathome = {
      enable = true;
      daemonNiceLevel = 5;
      extraArgs = [
        "--config=${config.sops.secrets."foldingAtHome/config.xml".path}"
        "--machine-name=${config.setup.hostname}"
      ];
    };

    # Currently this runs the service as root, which is obviously bad because
    # Folding@home downloads and runs untrusted binary blobs, so this is quite
    # insecure, but at least it works.

    # Personally I trust the binaries because Folding@home is a long-running
    # project being run and managed by trusted scientists and programmers, and
    # large parts of the project are open source. Still, running everything as
    # root is rather sub-optimal. Hardening the systemd service helps a lot,
    # but it's still not perfect.

    # The default config uses a dynamic user but for me, every time fah-client
    # tries to start a subprocess, it fails immediately. Specifically, execve
    # returns -1 (EACCES), which I don't know how to solve.

    # If I create a custom static system user and run the systemd service as
    # that user, bwrap complains that it can't set up the uid map. I think
    # that's because `setfsuid(0)` fails as an unprivileged user, but it works
    # when I run fah-client myself so I'm not sure.

    # I could instead override the version of buildFHSEnv that pkgs.fahclient
    # uses to add my own arguments to bwrap and run the systemd service as
    # root, but all the children still get run as root, so I'm not sure what's
    # going on there either.

    systemd = {
      services.foldingathome.serviceConfig = {
        DynamicUser = lib.mkForce false;

        StateDirectory = "foldingathome";
        WorkingDirectory = lib.mkForce "/var/lib/foldingathome";

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
        ReadWritePaths = [ "/var/lib/foldingathome" ];

        RestrictRealtime = true;
        RestrictSUIDSGID = true;
        SystemCallArchitectures = "native";
        MemoryDenyWriteExecute = true;

        AmbientCapabilities = [ "CAP_SYS_ADMIN" ];
        CapabilityBoundingSet = [ "CAP_SYS_ADMIN" ];
        SystemCallFilter = [
          "@system-service"
          "@mount"
        ];
      };
    };
  };
}
