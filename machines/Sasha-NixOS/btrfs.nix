{
  services = {
    btrfs.autoScrub = {
      enable = true;
      fileSystems = [
        "/"
        "/data"
      ];
      limit = "16M"; # Throughput
    };

    beesd.filesystems = {
      root = {
        spec = "LABEL=NixOS";
        hashTableSizeMB = 128;
      };
      data = {
        spec = "LABEL=data";
        hashTableSizeMB = 128;
      };
    };
  };
}
