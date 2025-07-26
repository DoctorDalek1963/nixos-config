{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  clipse = "${pkgs.clipse}/bin/clipse";

  terminal-command =
    {
      wezterm = "$launchInTerminal --class clipse ${clipse}";
      terminator = abort "Terminator doesn't support setting a custom class, so cannot be used for clipse in the current setup";
    }
    .${config.setup.terminal.emulator};
in
{
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home.packages = [ pkgs.wl-clipboard ];

    wayland.windowManager.hyprland.settings = {
      exec-once = [ "${clipse} -listen" ];

      windowrulev2 = [
        "float, class:(clipse)"
        "size 622 652, class:(clipse)"
      ];
      bind = [ "SUPER, V, exec, $launchPrefix ${terminal-command}" ];
    };
  };
}
