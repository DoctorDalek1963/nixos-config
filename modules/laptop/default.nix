{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.isLaptop {
    services = {
      # Conflicts with TLP
      power-profiles-daemon.enable = false;

      thermald.enable = true;

      tlp = {
        enable = true;
        settings = {
          CPU_ENERGY_PERF_POLICY_ON_AC = "performance";
          CPU_SCALING_GOVERNOR_ON_AC = "performance";

          CPU_ENERGY_PERF_POLICY_ON_BAT = "power";
          CPU_SCALING_GOVERNOR_ON_BAT = "powersave";

          CPU_MIN_PERF_ON_AC = 0;
          CPU_MAX_PERF_ON_AC = 100;
          CPU_MIN_PERF_ON_BAT = 0;
          CPU_MAX_PERF_ON_BAT = 50;

          # Helps save long term battery health
          START_CHARGE_THRESH_BAT0 = 40; # Only charge when below 40%
          STOP_CHARGE_THRESH_BAT0 = 80; # Stop charging above 80%
        };
      };
    };
  };
}
