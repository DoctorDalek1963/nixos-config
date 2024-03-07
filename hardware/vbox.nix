{lib, ...}: {
  boot = {
    initrd = {
      availableKernelModules = ["ata_piix" "ohci_pci" "sd_mod" "sr_mod"];
      kernelModules = [];
    };
    kernelModules = [];
    extraModulePackages = [];
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/0003df8f-16c1-400c-8794-7877a0a53a06";
      fsType = "ext4";
    };

    "home" = {
      device = "/dev/disk/by-uuid/3da0adf9-ee25-4e2f-8cce-399a3524ebbf";
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
