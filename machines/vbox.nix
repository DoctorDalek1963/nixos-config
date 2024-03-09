{
  networking.hostName = "VirtualBox-NixOS";
  system.stateVersion = "23.11";

  virtualisation.virtualbox.guest.enable = true;

  services.xserver.displayManager.gdm.wayland = false;

  imports = [
    ../hardware/vbox.nix
    ../modules/core.nix
  ];
}
