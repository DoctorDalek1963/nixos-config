{
  lib,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    # Hint Electron apps to use Wayland
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {};

      plugins = [];

      systemd.variables = ["--all"];
    };
  };
}
