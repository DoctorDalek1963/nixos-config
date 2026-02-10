{
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
  };
}
