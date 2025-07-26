{
  pkgs,
  lib,
  # osConfig,
  ...
}:
{
  config = lib.mkIf false {
    # osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland = {
      plugins = [ pkgs.hyprlandPlugins.hyprspace ];

      settings = {
        bind = [ "$mod, Z, overview:toggle" ];

        # See https://github.com/KZDKM/Hyprspace#configuration
        plugin.overview = {
          showNewWorkspace = false;
          showEmptyWorkspace = false;
        };
      };
    };
  };
}
