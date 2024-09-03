{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.isGraphical {
    services = {
      # Wayland, for my use cases, is just not ready.
      # Maybe try again in 2026 or something
      xserver.displayManager.gdm.wayland = lib.mkDefault false;
      displayManager.sddm.wayland.enable = lib.mkDefault false;
    };
  };
}
