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

      windowrule = [
        {
          name = "clipse";

          "match:class" = "clipse";

          float = true;
          size = "622 652";
        }
      ];

      bind = [ "SUPER, V, exec, $launchPrefix ${terminal-command}" ];
    };
  };
}
