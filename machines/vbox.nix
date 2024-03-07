{
  networking.hostName = "VirtualBox-NixOS";
  boot.loader.grub.device = "/dev/sda";
  system.stateVersion = "23.11";

  virtualisation.virtualbox.guest.enable = true;

  imports = [
    ../hardware/vbox.nix
    ../modules/core.nix
  ];
}
