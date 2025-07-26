{
  disko.devices = {
    # 350 GB HDD
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
              extraArgs = [
                "-f"
                "--label"
                "NixOS"
              ];

              subvolumes =
                let
                  mount-options = compression-level: [
                    "compress=zstd:${compression-level}"
                    "noatime"
                  ];
                in
                {
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
                };
            };
          };
        };
      };
    };
  };

  fileSystems."/persist".neededForBoot = true;
}
