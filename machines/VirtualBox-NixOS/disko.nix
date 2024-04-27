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
            luks = {
              size = "100%";
              content = {
                type = "luks";
                name = "cryptrootsda";
                passwordFile = "/tmp/password";
                settings.allowDiscards = true;

                content = {
                  type = "lvm_pv";
                  vg = "pool";
                };
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
          partitions.luks = {
            size = "100%";
            content = {
              type = "luks";
              name = "cryptrootsdb";
              passwordFile = "/tmp/password";
              settings.allowDiscards = true;

              content = {
                type = "lvm_pv";
                vg = "pool";
              };
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
          subvolumes = let
            mountOptions = ["compress=zstd:2" "noatime"];
          in {
            "/rootfs" = {
              inherit mountOptions;
              mountpoint = "/";
            };
            "/home" = {
              inherit mountOptions;
              mountpoint = "/home";
            };
            "/home/.snapshots" = {
              inherit mountOptions;
              mountpoint = "/home/.snapshots";
            };
            "/nix" = {
              inherit mountOptions;
              mountpoint = "/nix";
            };
          };
        };
      };
    };
  };
}
