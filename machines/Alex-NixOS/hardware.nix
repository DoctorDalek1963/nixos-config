{
  pkgs,
  lib,
  config,
  modulesPath,
  ...
}: {
  imports = [
    (modulesPath + "/installer/scan/not-detected.nix")
  ];

  boot = {
    initrd = {
      availableKernelModules = ["nvme" "xhci_pci" "ahci" "usb_storage" "usbhid" "sd_mod"];
      kernelModules = [];
    };

    kernelModules = ["kvm-amd"];
    extraModulePackages = [];

    loader = {
      grub = {
        enable = true;
        device = "nodev";
        efiSupport = true;
        timeoutStyle = "hidden";
      };
      efi.canTouchEfiVariables = true;
      timeout = 2;
    };
  };

  swapDevices = [];

  nix.settings.max-jobs = 12;

  hardware = {
    graphics = {
      enable = true;
      enable32Bit = true;
    };

    amdgpu.opencl.enable = true;
  };

  systemd.tmpfiles.rules = ["L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}"];

  # Taken from https://blog.wjt.je/running-foldingathome-on-nixos-with-opencl-support-for-amd-gpu
  # to support Folding@home
  environment.variables.OCL_ICD_VENDORS = "${pkgs.rocmPackages.clr.icd}/etc/OpenCL/vendors/";

  # Enables DHCP on each ethernet and wireless interface. In case of scripted networking
  # (the default) this is the recommended approach. When using systemd-networkd it's
  # still possible to use this option, but it's recommended to use it in conjunction
  # with explicit per-interface declarations with `networking.interfaces.<interface>.useDHCP`.
  networking.useDHCP = lib.mkDefault true;
  # networking.interfaces.eno1.useDHCP = lib.mkDefault true;
  # networking.interfaces.wlp9s0.useDHCP = lib.mkDefault true;

  nixpkgs.hostPlatform = lib.mkDefault "x86_64-linux";
  hardware.cpu.amd.updateMicrocode = lib.mkDefault config.hardware.enableRedistributableFirmware;
}
