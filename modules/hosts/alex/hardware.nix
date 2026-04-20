{
  flake.aspects =
    { aspects, ... }:
    {
      host-alex = {
        includes = [
          aspects.lanzaboote
        ];

        nixos =
          {
            pkgs,
            config,
            ...
          }:
          {
            boot = {
              initrd = {
                availableKernelModules = [
                  "nvme"
                  "xhci_pci"
                  "ahci"
                  "usb_storage"
                  "usbhid"
                  "sd_mod"
                ];
                kernelModules = [ ];
              };

              kernelModules = [ "kvm-amd" ];
              extraModulePackages = [ ];
            };

            swapDevices = [ ];

            nix.settings.max-jobs = 12;

            hardware = {
              graphics = {
                enable = true;
                enable32Bit = true;
              };

              amdgpu.opencl.enable = true;
            };

            systemd.tmpfiles.rules = [ "L+ /opt/rocm/hip - - - - ${pkgs.rocmPackages.clr}" ];

            # Taken from https://blog.wjt.je/running-foldingathome-on-nixos-with-opencl-support-for-amd-gpu
            # to support Folding@home
            environment.variables.OCL_ICD_VENDORS = "${pkgs.rocmPackages.clr.icd}/etc/OpenCL/vendors/";

            networking.useDHCP = true;
            hardware.cpu.amd.updateMicrocode = config.hardware.enableRedistributableFirmware;
          };
      };
    };
}
