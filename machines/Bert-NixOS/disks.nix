{
  fileSystems = {
    "/data" = {
      device = "/dev/sda1";
      fsType = "btrfs";
      options = [
        "compress=zstd:2"
        "discard=async"
        "noatime"
        "subvol=/data"
      ];
    };
  };

  # I'm deliberately not going to use Disko for Bert because he's a Raspberry
  # Pi running off an SD card, so I do fresh installs using a disk image. But
  # for future home server setups, here's what my current (2025-04-12) external
  # hard drive setup would look like with Disko.

  # Obviously be VERY VERY careful not to destroy data on these drives when
  # installing new home server setups. Maybe it would be better to never
  # declare them with disko and just use fileSystems like above to avoid the
  # possible accident? But that's why we keep backups!

  # disko.devices = {
  #   disk.sda = {
  #     device = "/dev/sda";
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
  #                   "discard=async"
  #                   "noatime"
  #                 ];
  #                 mountpoint = "/data";
  #               };
  #             };
  #           };
  #         };
  #       };
  #     };
  #   };
  # };
}
