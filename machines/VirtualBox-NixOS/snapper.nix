{
  services.snapper = {
    cleanupInterval = "0/6:00:00";
    snapshotInterval = "0/6:00:00";

    configs.home = {
      SUBVOLUME = "/home";
      FSTYPE = "btrfs";
      ALLOW_USERS = ["dyson"];
      TIMELINE_CREATE = true;
      TIMELINE_CLEANUP = true;
      TIMELINE_LIMIT_DAILY = 14;
    };
  };
}
