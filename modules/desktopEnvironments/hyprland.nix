{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.desktopEnvironments.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    services.power-profiles-daemon.enable = true;
  };
}
