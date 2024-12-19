{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfgTE = config.setup.terminal.emulators;
in {
  imports = [./clipboard.nix ./hyprpaper.nix ./waybar.nix ./wofi.nix];

  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    # Hint Electron apps to use Wayland
    home.sessionVariables.NIXOS_OZONE_WL = "1";

    wayland.windowManager.hyprland = {
      enable = true;

      settings = let
        wpctl = "${pkgs.wireplumber}/bin/wpctl";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        hyprnome = "${pkgs.hyprnome}/bin/hyprnome";
      in {
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

          # Hovering over a window won't focus it until you click
          follow_mouse = 2;
        };

        general = {
          border_size = 2;
          gaps_in = 5;
          gaps_out = 10;

          layout = "dwindle";
        };

        decoration = {
          rounding = 7;

          dim_inactive = true;
          dim_strength = 0.15;
        };

        gestures = {
          workspace_swipe = true;
          workspace_swipe_fingers = 4;
        };

        misc = {
          disable_hyprland_logo = true;
          force_default_wallpaper = 0;

          # If one window is fullscreen and another window is opened,
          # then disable fullscreen
          new_window_takes_over_fullscreen = 2;
        };

        animation = [
          "windows, 1, 2.5, easeInOutQuart"
          "workspaces, 1, 2.5, easeInOutQuart"
        ];

        bezier = [
          "easeInOutSine, 0.37, 0, 0.63, 1"
          "easeInOutQuad, 0.45, 0, 0.55, 1"
          "easeInOutCubic, 0.65, 0, 0.35, 1"
          "easeInOutQuart, 0.76, 0, 0.24, 1"
          "easeInOutQuint, 0.83, 0, 0.17, 1"
        ];

        bind =
          # General window management
          [
            "$mod, Q, killactive,"
            "$mod SHIFT, F, fullscreen, 1"
            "$mod ALT, F, togglefloating,"
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
