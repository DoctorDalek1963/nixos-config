{
  disko.devices = {
    # 1 TB SSD
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
          swap = {
            size = "8G";
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
                  "/persist" = {
                    mountOptions = mount-options "2";
                    mountpoint = "/persist";
                  };
                  "/persist/home" = {
                    # We have enough space to afford not to compress /home,
                    # since this is where all my games are stored and I don't
                    # need the performance hit of compression
                    mountOptions = ["discard=async" "noatime"];
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

  fileSystems."/persist".neededForBoot = true;
}
