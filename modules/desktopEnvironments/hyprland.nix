{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.desktopEnvironments.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;
    };

    programs.dconf.enable = true;
  };
}
