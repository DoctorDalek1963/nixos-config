{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.virtualBox.guest.enable {
    virtualisation.virtualbox.guest.enable = true;

    # I've had some issues with graphics controllers and NixOS in VirtualBox. If
    # I disable Wayland in the VM and use VBoxVGA, then it seems to work properly
    # and allow screen resizing.
    services.displayManager.gdm.wayland = false;
  };
}
