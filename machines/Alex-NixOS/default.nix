{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko ./disko.nix ./hardware.nix ./snapper.nix];

  # TODO: Uncomment this when we're on 24.05
  # Currently the VirtualBox 7.0.14 host modules fail to build for Linux 6.9.1.
  # I assume this is a problem with unstable and will hopefully be fixed once
  # I'm back on a stable channel
  # boot.kernelPackages = pkgs.linuxPackages_latest;
}
