{
  disko.devices = {
    # 120 GB SSD
    disk.nvme0n1 = {
      device = "/dev/nvme0n1";
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
          luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptroot";
              passwordFile = "/tmp/password";
              settings.allowDiscards = true;

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
                  "/home" = {
                    mountOptions = mount-options "2";
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
  };
}
