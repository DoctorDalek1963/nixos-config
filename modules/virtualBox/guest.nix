{config, ...}: let
  guest-enabled = config.setup.virtualBox.guest.enable;
in {
  virtualisation.virtualbox.guest.enable = guest-enabled;

  # I've had some issues with graphics controllers and NixOS in VirtualBox. If
  # I disable Wayland in the VM and use VBoxVGA, then it seems to work properly
  # and allow screen resizing.
  services.xserver.displayManager.gdm.wayland = !guest-enabled;
}
