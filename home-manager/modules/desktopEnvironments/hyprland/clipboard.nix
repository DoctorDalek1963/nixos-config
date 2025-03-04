{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home.packages = [pkgs.wl-clipboard];

    wayland.windowManager.hyprland.settings = let
      clipse = "${pkgs.clipse}/bin/clipse";
    in {
      exec-once = ["${clipse} -listen"];

      windowrulev2 = [
        "float, class:(clipse)"
        "size 622 652, class:(clipse)"
      ];
      bind = ["SUPER, V, exec, $launchPrefix ${config.programs.wezterm.package}/bin/wezterm --config 'window_close_confirmation=\"NeverPrompt\"' start --always-new-process --class clipse ${clipse}"];
    };
  };
}
