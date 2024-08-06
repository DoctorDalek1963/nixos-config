{
  disko.devices = {
    # 2 TB HDD
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
            size = "8G";
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
                  "noatime"
                ];
              in {
                "/rootfs" = {
                  mountOptions = mount-options "2";
                  mountpoint = "/";
                };
                "/home" = {
                  mountOptions = ["discard=async" "noatime"];
                  mountpoint = "/home";
                };
                "/home/.snapshots" = {
                  mountOptions = mount-options "5";
                  mountpoint = "/home/.snapshots";
                };
                "/nix" = {
                  mountOptions = mount-options "2";
                  mountpoint = "/nix";
                };
              };
            };
          };
        };
      };
    };
  };
}
