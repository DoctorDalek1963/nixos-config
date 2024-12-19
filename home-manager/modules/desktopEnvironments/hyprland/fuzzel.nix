{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: {
  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    wayland.windowManager.hyprland.settings = {
      bind = ["$mod, R, exec, ${config.programs.fuzzel.package}/bin/fuzzel"];
    };

    programs.fuzzel = {
      enable = true;

      settings = {
        main = {
          font = "Hack Nerd Font Mono";
          use-bold = true;
          icons-enabled = true;
          terminal = "${pkgs.wezterm}/bin/wezterm start --always-new-process";
        };
      };
    };
  };
}
