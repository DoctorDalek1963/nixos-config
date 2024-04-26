{
  services.snapper = {
    cleanupInterval = "daily";
    snapshotInterval = "daily";

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
