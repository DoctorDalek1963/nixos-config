{lib, ...}: {
  boot = {
    initrd = {
      availableKernelModules = ["ata_piix" "ohci_pci" "sd_mod" "sr_mod"];
      kernelModules = [];
    };

    kernelModules = [];
    extraModulePackages = [];

    loader.grub = {
      enable = true;
      useOSProber = true;
      device = "/dev/sda";
    };
  };

  fileSystems = {
    "/" = {
      device = "/dev/disk/by-uuid/c2459017-b98c-4f91-9b42-ca472d5f4368";
      fsType = "ext4";
    };

    "home" = {
      device = "/dev/disk/by-uuid/6566c69a-e1cb-468e-a73f-fd5ab689b38f";
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
