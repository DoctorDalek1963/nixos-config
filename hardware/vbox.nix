{lib, ...}: {
  boot = {
    initrd = {
      availableKernelModules = ["ata_piix" "ohci_pci" "ehci_pci" "ahci" "sd_mod" "sr_mod"];
      kernelModules = [];
    };

    kernelModules = [];
    extraModulePackages = [];

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        useOSProber = true;
      };
      efi.canTouchEfiVariables = true;
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/a9febf3b-7dd2-49dc-aab4-31727cb49fc7";
      fsType = "ext4";
    };

    "/boot" = {
      device = "/dev/disk/by-uuid/D177-989D";
      fsType = "vfat";
    };

    "/home" = {
      device = "/dev/disk/by-uuid/298c2c29-6db8-4be0-9863-aa5fe62e8e3d";
      fsType = "ext4";
    };
  };

  swapDevices = [];

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.enp0s3.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
}
