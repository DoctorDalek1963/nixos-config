{
  pkgs,
  lib,
  osConfig,
  ...
}:
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home.packages = [ pkgs.sunsetr ];

    wayland.windowManager.hyprland.settings.exec-once = [ (lib.getExe pkgs.sunsetr) ];

    xdg.configFile."sunsetr/sunsetr.toml".source =
      (pkgs.writers.writeTOML "sunsetr.toml" {
        # Sunsetr configuration
        backend = "wayland";
        start_hyprsunset = false;

        startup_transition = true;
        startup_transition_duration = 1; # Seconds

        day_temp = 6500;
        day_gamma = 100;

        night_temp = 3500;
        night_gamma = 80;

        update_interval = 60; # Seconds
        transition_mode = "geo";

        # Manual transitions, unused but required
        sunset = "19:00:00";
        sunrise = "07:00:00";
        transition_duration = 45; # Minutes

        # Geolocation-based transitions. Location is London
        latitude = 51.508415;
        longitude = -0.125533;
      }).outPath;
  };
}
