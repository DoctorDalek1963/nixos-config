{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.desktopEnvironments.hyprland.enable {
    programs.hyprland = {
      enable = true;
      withUWSM = true;

      package = lib.mkIf config.programs.hyprland.withUWSM (
        pkgs.hyprland.overrideAttrs (oldAttrs: {
          nativeBuildInputs = (oldAttrs.nativeBuildInputs or [ ]) ++ [ pkgs.gnused ];

          postInstall =
            (oldAttrs.postInstall or "")
            +
            # bash
            ''
              sed -i "s|hyprland.desktop|$out/bin/start-hyprland|" $out/share/wayland-sessions/hyprland-uwsm.desktop
              rm $out/share/wayland-sessions/hyprland.desktop
            '';

          passthru.providedSessions = [ "hyprland-uwsm" ];
        })
      );
    };

    programs.dconf.enable = true;
  };
}
