{
  disko.devices = {
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
      };
    };
  };
}
