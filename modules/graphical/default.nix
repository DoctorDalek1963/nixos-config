{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.isGraphical {
    services = {
      # Audio with pipewire
      pipewire = {
        enable = true;
        alsa = {
          enable = true;
          support32Bit = true;
        };
        pulse.enable = true;
        # jack.enable = true;
      };

      xserver = {
        enable = true;
        # Use British keyboard in graphical sessions
        xkb.layout = "gb";
      };
    };

    # Enable sound
    sound.enable = lib.mkDefault true;
    hardware.pulseaudio.enable = false;
    security.rtkit.enable = true;
  };
}
