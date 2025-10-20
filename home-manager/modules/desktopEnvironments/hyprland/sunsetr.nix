{
  pkgs,
  lib,
  osConfig,
  ...
}:
let
  sunsetr-config = {
    backend = "hyprland";

    smoothing = true;
    startup_duration = 1; # Seconds
    shutdown_duration = 1; # Seconds

    day_temp = 6500;
    day_gamma = 100;

    night_temp = 3500;
    night_gamma = 80;

    update_interval = 60; # Seconds
    transition_mode = "geo";

    # Geolocation-based transitions. Location is London
    latitude = 51.508415;
    longitude = -0.125533;
  };
in
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home.packages = [ pkgs.sunsetr ];

    wayland.windowManager.hyprland.settings.exec-once = [ (lib.getExe pkgs.sunsetr) ];

    xdg.configFile = {
      "sunsetr/sunsetr.toml".source = (pkgs.writers.writeTOML "sunsetr.toml" sunsetr-config).outPath;

      "sunsetr/presets/gaming/sunsetr.toml".source =
        (pkgs.writers.writeTOML "sunsetr.toml" (
          sunsetr-config
          // {
            night_temp = 4500;
            night_gamma = 95;
          }
        )).outPath;
    };
  };
}
