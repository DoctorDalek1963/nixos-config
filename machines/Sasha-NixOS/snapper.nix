{
  services.snapper = {
    cleanupInterval = "0/6:00:00";
    snapshotInterval = "0/6:00:00";

    configs.home = {
      SUBVOLUME = "/home";
      FSTYPE = "btrfs";
      ALLOW_USERS = ["dyson" "rebecca"];
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
}
