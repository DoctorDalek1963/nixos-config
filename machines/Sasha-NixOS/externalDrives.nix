{
  fileSystems = {
    "/data" = {
      device = "/dev/disk/by-partlabel/disk-data-data";
      fsType = "btrfs";
      options = [
        "compress=zstd:2"
        "noatime"
        "subvol=/data"
      ];
    };
    "/data/.snapshots" = {
      device = "/dev/disk/by-partlabel/disk-data-data";
      fsType = "btrfs";
      options = [
        "compress=zstd:5"
        "noatime"
        "subvol=/data/.snapshots"
      ];
    };
  };

  # I'm deliberately not declaring the external /data drive with disko so that
  # I don't accidentally wipe it when reinstalling, but the disko config is below.

  # To deliberately wipe the disk, MAKE BACKUPS, uncomment this block, make
  # sure the device is correct, and run:
  # sudo nix run github:nix-community/disko -- --mode destroy,format,mount machines/Sasha-NixOS/externalDrives.nix

  # disko.devices = {
  #   disk.data = {
  #     device = "/dev/sdb";
  #     type = "disk";
  #     content = {
  #       type = "gpt";
  #       partitions = {
  #         data = {
  #           size = "100%";
  #           content = {
  #             type = "btrfs";
  #
  #             subvolumes = {
  #               "/data" = {
  #                 mountOptions = [
  #                   "compress=zstd:2"
  #                   "noatime"
  #                 ];
  #                 mountpoint = "/data";
  #               };
  #               "/data/.snapshots" = {
  #                 mountOptions = [
  #                   "compress=zstd:5"
  #                   "noatime"
  #                 ];
  #                 mountpoint = "/data/.snapshots";
  #               };
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
