{
  disko.devices = {
    disk = {
      sda = {
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
                resumeDevice = true;
              };
            };
            root = {
              size = "100%";
              content = {
                type = "lvm_pv";
                vg = "pool";
              };
            };
          };
        };
      };
      sdb = {
        device = "/dev/sdb";
        type = "disk";
        content = {
          type = "gpt";
          partitions.root = {
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };

    lvm_vg.pool = {
      type = "lvm_vg";
      lvs.root = {
        size = "100%VG"; # The whole volume group
        content = {
          type = "btrfs";
          extraArgs = ["-f" "--label" "NixOS"];
          subvolumes = {
            "/rootfs" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "/";
            };
            "/home" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "/home";
            };
            "/home/.snapshots" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "/home/.snapshots";
            };
            "/nix" = {
              mountOptions = ["compress=zstd" "noatime"];
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
