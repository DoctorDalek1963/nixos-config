{
  networking.hostName = "VirtualBox-NixOS";
  system.stateVersion = "23.11";

  virtualisation.virtualbox.guest.enable = true;

  # I've had some issues with graphics controllers and NixOS in VirtualBox. If
  # I disable Wayland in the VM and use VBoxVGA, then it seems to work properly
  # and allow screen resizing.
  services.xserver.displayManager.gdm.wayland = false;

  imports = [
    ../hardware/vbox.nix
    ../modules/core.nix
    ../modules/gnome.nix
  ];
}
