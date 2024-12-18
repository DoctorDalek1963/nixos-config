{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfgTE = config.setup.terminal.emulators;

  wpctl = "${pkgs.wireplumber}/bin/wpctl";
  playerctl = "${pkgs.playerctl}/bin/playerctl";
  hyprnome = "${pkgs.hyprnome}/bin/hyprnome";
in {
  imports = [./clipboard.nix ./wofi.nix];

  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    # Hint Electron apps to use Wayland
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    wayland.windowManager.hyprland = {
      enable = true;

      settings = {
        monitor = ", preferred, auto, auto";

        "$mod" = "SUPER";

        "$terminal" =
          if cfgTE.wezterm
          # FIXME: We should be able to remove "[float; tile]" after the next Wezterm release
          then "[float; tile] ${pkgs.wezterm}/bin/wezterm start --always-new-process"
          else if cfgTE.terminator
          then "${pkgs.terminator}/bin/terminator -x"
          else abort "Please enable a terminal emulator";

        input = {
          kb_layout = "gb";
          kb_options = "caps:escape, compose:menu";
          numlock_by_default = true;
        };

        general.layout = "dwindle";

        bind =
          # General window management
          [
            "$mod, Q, killactive,"
            "$mod SHIFT, F, fullscreen, 1"
          ]
          # Spawn new windows
          ++ [
            "$mod, T, exec, $terminal"
            # "$mod, E, exec, $fileManager"
            "$mod, F, exec, ${config.programs.firefox.package}/bin/firefox"
          ]
          # Move focus
          ++ [
            "$mod, left, movefocus, l"
            "$mod, down, movefocus, d"
            "$mod, up, movefocus, u"
            "$mod, right, movefocus, r"
            "$mod, H, movefocus, l"
            "$mod, J, movefocus, d"
            "$mod, K, movefocus, u"
            "$mod, L, movefocus, r"
          ]
          # Move windows
          ++ [
            "$mod SHIFT, left, movewindow, l"
            "$mod SHIFT, down, movewindow, d"
            "$mod SHIFT, up, movewindow, u"
            "$mod SHIFT, right, movewindow, r"
            "$mod SHIFT, H, movewindow, l"
            "$mod SHIFT, J, movewindow, d"
            "$mod SHIFT, K, movewindow, u"
            "$mod SHIFT, L, movewindow, r"
          ]
          # Move focus or window to relative workspace
          ++ [
            "$mod ALT, left, exec, ${hyprnome} --previous"
            "$mod ALT, right, exec, ${hyprnome}"
            "$mod ALT, H, exec, ${hyprnome} --previous"
            "$mod ALT, L, exec, ${hyprnome}"
            "$mod ALT SHIFT, left, exec, ${hyprnome} --previous --move"
            "$mod ALT SHIFT, right, exec, ${hyprnome} --move"
            "$mod ALT SHIFT, H, exec, ${hyprnome} --previous --move"
            "$mod ALT SHIFT, L, exec, ${hyprnome} --move"
          ]
          # Move focus or window to explicit workspace
          ++ (
            # binds $mod + [shift +] {1..0} to [move to] workspace {1..10}
            builtins.concatLists (builtins.genList (
                i: let
                  workspace = toString (i + 1);
                  button = toString (lib.mod (i + 1) 10); # Button 0 for workspace 10
                in [
                  "$mod, ${button}, workspace, ${workspace}"
                  "$mod SHIFT, ${button}, movetoworkspace, ${workspace}"
                ]
              )
              10)
          )
          # Mute button
          ++ [
            ", Xf86AudioMute, exec, ${wpctl} set-mute @DEFAULT_AUDIO_SINK@ toggle"
            ", Xf86AudioPlay, exec, ${playerctl} play-pause"
            ", Xf86AudioPrev, exec, ${playerctl} previous"
            ", Xf86AudioNext, exec, ${playerctl} next"
          ];

        # Binds that repeat when held
        binde =
          # Volume controls
          [
            ", Xf86AudioRaiseVolume, exec, ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ .05+"
            ", Xf86AudioLowerVolume, exec, ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ .05-"
            "CTRL, up, exec, ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ .05+"
            "CTRL, down, exec, ${wpctl} set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ .05-"
          ];
      };

      plugins = [];

      systemd.variables = ["--all"];
    };
  };
}
