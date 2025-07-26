{
  lib,
  config,
  ...
}:
{
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

    # RealtimeKit needed by pipewire
    security.rtkit.enable = true;
  };
}
