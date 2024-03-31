{config, ...}: {
  virtualisation.virtualbox.guest.enable = config.setup.virtualBoxGuest;

  # I've had some issues with graphics controllers and NixOS in VirtualBox. If
  # I disable Wayland in the VM and use VBoxVGA, then it seems to work properly
  # and allow screen resizing.
  services.xserver.displayManager.gdm.wayland = !config.setup.virtualBoxGuest;
}
