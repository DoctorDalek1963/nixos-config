{
  disko.devices = {
    # 220 GB SSD
    disk.sda = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          ESP = {
            type = "EF00";
            size = "512M";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          swap = {
            size = "4G";
            content = {
              type = "swap";
              randomEncryption = true;
            };
          };
          nixos = {
            size = "100%";
            content = {
              type = "btrfs";
              extraArgs = ["-f" "--label" "NixOS"];

              subvolumes = let
                mount-options = compression-level: [
                  "compress=zstd:${compression-level}"
                  "discard=async"
                  "noatime"
                ];
              in {
                "/rootfs" = {
                  mountOptions = mount-options "2";
                  mountpoint = "/";
                };
                "/nix" = {
                  mountOptions = mount-options "2";
                  mountpoint = "/nix";
                };
                "/home" = {
                  mountOptions = mount-options "2";
                  mountpoint = "/home";
                };
                "/home/.snapshots" = {
                  mountOptions = mount-options "5";
                  mountpoint = "/home/.snapshots";
                };
              };
            };
          };
        };
      };
    };
  };
}
