{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup;
  cfgTE = cfg.terminal.emulators;
  cfgTT = cfg.terminal.tools;
  cfgB = cfg.desktopEnvironments.hyprland.borderStyle;

  theme-colors =
    {
      "catppuccin-macchiato-mauve" = let
        active_colours =
          if cfgB.rainbow
          then ["ed8796" "f5a97f" "eed49f" "a6da95" "8aadf4" "c6a0f6"] # Red, Peach, Yellow, Green, Blue, Mauve
          else ["c6a0f6" "b7bdf8"]; # Mauve to Lavender
      in {
        "col.active_border" = "${
          lib.concatStringsSep " "
          (builtins.map (colour: "rgba(${colour}ff)") active_colours)
        } 45deg";
        "col.inactive_border" = "rgba(494d64ff)"; # Surface 1
      };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};
in {
  imports = [
    ./clipboard.nix
    ./fuzzel.nix
    ./gtk.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpanel.nix
    ./hyprpaper.nix
  ];

  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home = {
      # Hint Electron apps to use Wayland
      sessionVariables.NIXOS_OZONE_WL = "1";
      packages = [pkgs.hyprpolkitagent];
    };

    wayland.windowManager.hyprland = {
      enable = true;

      systemd = {
        enable = !osConfig.programs.hyprland.withUWSM;
        variables = ["--all"];
      };

      settings = let
        wpctl = "${pkgs.wireplumber}/bin/wpctl";
        playerctl = "${pkgs.playerctl}/bin/playerctl";
        hyprnome = "${pkgs.hyprnome}/bin/hyprnome";
      in {
        exec-once = ["systemctl --user start hyprpolkitagent"];

        env = ["NIXOS_OZONE_WL,1"];

        monitor = [", preferred, auto, 1"];

        "$mod" = "SUPER";

        "$launchPrefix" =
          if osConfig.programs.hyprland.withUWSM
          then "${osConfig.programs.uwsm.package}/bin/uwsm app --"
          else "";

        "$terminal" =
          if cfgTE.wezterm
          then "${pkgs.wezterm}/bin/wezterm start --always-new-process"
          else if cfgTE.terminator
          then "${pkgs.terminator}/bin/terminator -x"
          else abort "Please enable a terminal emulator";

        "$fileManager" =
          if cfgTT.yazi
          then
            (
              # I know this is horrible, but I want to pass a custom config
              # param to Wezterm only when using Wezterm and Yazi together so
              # that Super+Q closes the terminal immediately, and this is the
              # easiest way to do that
              if cfgTE.wezterm
              then "${pkgs.wezterm}/bin/wezterm --config 'window_close_confirmation=\"NeverPrompt\"' start --always-new-process ${config.programs.yazi.package}/bin/yazi"
              else if cfgTE.terminator
              then "${pkgs.terminator}/bin/terminator -x ${config.programs.yazi.package}/bin/yazi"
              else abort "Please enable a terminal emulator"
            )
          else abort "Please enable a file manager";

        input = {
          kb_layout = "gb";
          kb_options = "caps:escape, compose:menu";
          numlock_by_default = true;

          # Hovering over a window won't focus it until you click
          follow_mouse = 2;
        };

        "input:touchpad".natural_scroll = true;

        general = {
          gaps_in = 5;
          gaps_out = 10;

          layout = "dwindle";

          border_size = 2;
          resize_on_border = true;
          inherit (theme-colors) "col.active_border" "col.inactive_border";
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

        animation =
          [
            "windows, 1, 2.5, easeInOutQuart"
            "workspaces, 1, 2.5, easeInOutQuart"
          ]
          ++ (
            lib.optional cfgB.animateGradientAngle.enable
            "borderangle, 1, ${toString (10 * cfgB.animateGradientAngle.speedSecs)}, linear, loop"
          );

        bezier = [
          "linear, 0, 0, 1, 1"
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
            "$mod ALT, F, togglefloating,"
            ", F11, fullscreen, 2"
            "$mod, up, fullscreen, 1"
            "$mod SHIFT, up, fullscreen, 2"
            "$mod, down, fullscreenstate, 0"
          ]
          # Spawn new windows
          ++ [
            "$mod, T, exec, $launchPrefix $terminal"
            "$mod, E, exec, $launchPrefix $fileManager"
            "$mod, F, exec, $launchPrefix ${config.programs.firefox.package}/bin/firefox"
            "$mod, O, exec, $launchPrefix ${pkgs.obsidian}/bin/obsidian"
          ]
          # Move focus
          ++ [
            "$mod, H, movefocus, l"
            "$mod, J, movefocus, d"
            "$mod, K, movefocus, u"
            "$mod, L, movefocus, r"
          ]
          # Move windows
          ++ [
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
          ]
          # Brightness controls
          ++ (let
            brightnessctl = "${pkgs.brightnessctl}/bin/brightnessctl";
          in [
            ", XF86MonBrightnessUp, exec, ${brightnessctl} set +5%"
            ", XF86MonBrightnessDown, exec, ${brightnessctl} set 5%-"
          ]);

        # Mouse binds
        bindm = [
          "$mod, mouse:272, movewindow"
          "$mod, mouse:273, resizewindow"
        ];
      };
    };
  };
}
