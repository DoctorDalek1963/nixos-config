{
  flake.aspects.host-alex = {
    nixos = {
      services = {
        btrfs.autoScrub = {
          enable = true;
          fileSystems = [ "/" ];
          limit = "64M"; # Throughput
        };

        beesd.filesystems.root = {
          spec = "LABEL=NixOS";
          hashTableSizeMB = 256;
        };

        snapper = {
          cleanupInterval = "4/6:00:00";
          snapshotInterval = "4/6:00:00";

          configs.home = {
            SUBVOLUME = "/persist/home";
            FSTYPE = "btrfs";
            ALLOW_USERS = [ "dyson" ];
            TIMELINE_CREATE = true;
            TIMELINE_CLEANUP = true;
            TIMELINE_LIMIT_HOURLY = 0;
            TIMELINE_LIMIT_DAILY = 14;
            TIMELINE_LIMIT_WEEKLY = 0;
            TIMELINE_LIMIT_MONTHLY = 0;
            TIMELINE_LIMIT_QUARTERLY = 0;
            TIMELINE_LIMIT_YEARLY = 0;
          };
        };
      };
    };
  };
}
