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
                randomEncryption = true;
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
                  extraArgs = ["-f" "--label" "nixos"];

                  postCreateHook = ''
                    mount -t btrfs /dev/disk/by-label/nixos /mnt
                    btrfs subvolume snapshot -r /mnt /mnt/rootfs-blank
                    umount /mnt
                  '';

                  subvolumes = let
                    mount-options = compression-level: ["compress=zstd:${compression-level}" "noatime"];
                  in {
                    "/rootfs" = {
                      mountOptions = mount-options "2";
                      mountpoint = "/";
                    };
                    "/nix" = {
                      mountOptions = mount-options "2";
                      mountpoint = "/nix";
                    };
                    "/persist" = {
                      mountOptions = mount-options "2";
                      mountpoint = "/persist";
                    };
                    "/persist/home" = {
                      mountOptions = mount-options "2";
                      mountpoint = "/persist/home";
                    };
                    "/persist/home/.snapshots" = {
                      mountOptions = mount-options "5";
                      mountpoint = "/persist/home/.snapshots";
                    };
                  };
                };
              };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
