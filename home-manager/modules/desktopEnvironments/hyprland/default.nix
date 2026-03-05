{
  pkgs,
  lib,
  config,
  osConfig,
  ...
}:
let
  cfg = config.setup;
  cfgTT = cfg.terminal.tools;
  cfgB = cfg.desktopEnvironments.hyprland.borderStyle;

  hypr-gamemode-sh = pkgs.writeShellApplication {
    name = "hypr-gamemode.sh";

    runtimeInputs = [
      pkgs.dunst
      pkgs.gawk
      pkgs.procps
      pkgs.sunsetr
      config.wayland.windowManager.hyprland.package
    ];

    text = ''
      HYPRGAMEMODE=$(hyprctl getoption animations:enabled | awk '$1=="int:" {print $2}')
      if [ "$HYPRGAMEMODE" = 1 ] ; then
          hyprctl --batch "\
              keyword animations:enabled 0;\
              keyword decoration:shadow:enabled 0;\
              keyword decoration:blur:enabled 0;\
              keyword general:gaps_in 0;\
              keyword general:gaps_out 0;\
              keyword general:border_size 1;\
              keyword general:col.active_border ${theme-colors.gamemode-active-border};\
              keyword decoration:rounding 0;\
              keyword decoration:dim_inactive 0;\
              keyword general:allow_tearing 1"
          dunstctl set-paused true
          pkill -USR1 waybar
          sunsetr preset gaming
      else
          hyprctl reload
          dunstctl set-paused false
          pkill -USR1 waybar
          sunsetr preset default
      fi
    '';
  };

  theme-colors =
    {
      "catppuccin-macchiato-mauve" =
        let
          active_colours =
            if cfgB.rainbow then
              [
                "ed8796" # Red
                "f5a97f" # Peach
                "eed49f" # Yellow
                "a6da95" # Green
                "8aadf4" # Blue
                "c6a0f6" # Mauve
              ]
            else
              [
                "c6a0f6" # Mauve
                "b7bdf8" # Lavender
              ];
        in
        {
          "col.active_border" = "${
            lib.concatStringsSep " " (map (colour: "rgba(${colour}ff)") active_colours)
          } 45deg";
          "col.inactive_border" = "rgba(494d64ff)"; # Surface 1
          gamemode-active-border = "rgba(5b6078ff)"; # Surface 2
        };
    }
    .${config.setup.desktopEnvironments.hyprland.theme};
in
{
  imports = [
    ./waybar

    ./clipboard.nix
    ./dunst.nix
    ./gtk.nix
    ./hypridle.nix
    ./hyprlock.nix
    ./hyprpaper.nix
    ./sunsetr.nix
    ./timewarrior.nix
    ./wofi.nix
  ];

  config = lib.mkIf osConfig.setup.desktopEnvironments.hyprland.enable {
    home = {
      # Hint Electron apps to use Wayland
      sessionVariables.NIXOS_OZONE_WL = "1";
      packages = [ pkgs.hyprpolkitagent ];
    };

    # Catppuccin macchiato (mauve), taken from https://github.com/SchweGELBin/catppuccin-hyprtoolkit
    xdg.configFile."hypr/hyprtoolkit.conf".text = ''
      background=0xff181926
      base=0xff24273a
      alternate_base=0xff1e2030
      text=0xffcad3f5
      bright_text=0xffb8c0e0
      accent=0xffc6a0f6
      accent_secondary=0xffb7bdf8
    '';

    wayland.windowManager.hyprland = {
      enable = true;

      systemd = {
        enable = !osConfig.programs.hyprland.withUWSM;
        variables = [ "--all" ];
      };

      settings =
        let
          playerctl = "${pkgs.playerctl}/bin/playerctl";
          hyprnome = "${pkgs.hyprnome}/bin/hyprnome";
          hyprshot = "${pkgs.hyprshot}/bin/hyprshot";
          downloads = config.xdg.userDirs.download;

          volume-adjust-pkg = pkgs.writeShellApplication {
            name = "volume-adjust";

            runtimeInputs = with pkgs; [
              wireplumber
              coreutils
              bc
              dunst
            ];

            text = ''
              if [ "$1" = "mute" ]; then
                wpctl set-mute @DEFAULT_AUDIO_SINK@ toggle
              else
                wpctl set-volume -l 1.5 @DEFAULT_AUDIO_SINK@ "$1"
              fi

              muted=""
              if [ "$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | tr ' ' '\n' | tail -1)" = "[MUTED]" ]; then
                muted=" [MUTED]"
              fi

              volume_float="$(wpctl get-volume @DEFAULT_AUDIO_SINK@ | tr ' ' '\n' | head -2 | tail -1)"
              volume="$(bc <<< "($volume_float * 100) / 1")"

              progress_hint_float="$(bc -l <<< "($volume / 150) * 100")"
              progress_hint="$(bc <<< "$progress_hint_float / 1")"

              dunstify "Volume$muted" "$volume / 150" --urgency=low --hints=int:value:"$progress_hint" --hints=string:x-dunst-stack-tag:volume-adjust
            '';
          };

          volume-adjust = lib.getExe volume-adjust-pkg;

          brightness-adjust-pkg = pkgs.writeShellApplication {
            name = "brightness-adjust";

            runtimeInputs = with pkgs; [
              brightnessctl
              bc
              dunst
            ];

            text = ''
              brightnessctl set "$1"

              current="$(brightnessctl --machine-readable get)"
              maximum="$(brightnessctl --machine-readable max)"

              brightness_float="$(bc <<< "scale=5; ($current * 100) / $maximum + 0.5")"
              brightness="$(bc <<< "$brightness_float / 1")"

              dunstify "Brightness" "''${brightness}%" --urgency=low --hints=int:value:"$brightness" --hints=string:x-dunst-stack-tag:brightness-adjust
            '';
          };

          brightness-adjust = lib.getExe brightness-adjust-pkg;

          zoom-change-pkg = pkgs.writeShellApplication {
            name = "zoom-change";

            runtimeInputs = [ pkgs.bc ];

            text = ''
              zoom="$(hyprctl getoption cursor:zoom_factor | awk '$1=="float:" {print $2}')"

              case "$1" in
                "=")
                  hyprctl keyword cursor:zoom_factor 1
                  ;;
                "-")
                  hyprctl keyword cursor:zoom_factor "$(bc <<< "x=$zoom - 0.5; if (x < 1) { x=1; }; x")"
                  ;;
                "+")
                  hyprctl keyword cursor:zoom_factor "$(bc <<< "$zoom + 0.5")"
                  ;;
              esac

            '';
          };

          zoom-change = lib.getExe zoom-change-pkg;
        in
        {
          exec-once = [ "systemctl --user start hyprpolkitagent" ];

          env = [ "NIXOS_OZONE_WL,1" ];

          monitor = [ ", preferred, auto, 1, vrr, 2" ];

          "$mod" = "SUPER";

          "$launchPrefix" =
            if osConfig.programs.hyprland.withUWSM then
              "${osConfig.programs.uwsm.package}/bin/uwsm app --"
            else
              "";

          "$terminal" =
            {
              wezterm = "${config.programs.wezterm.package}/bin/wezterm start --always-new-process";
              terminator = "${pkgs.terminator}/bin/terminator -x";
            }
            .${config.setup.terminal.emulator};

          "$launchInTerminal" =
            {
              wezterm = ''${config.programs.wezterm.package}/bin/wezterm --config 'window_close_confirmation="NeverPrompt"' start --always-new-process'';
              terminator = "${pkgs.terminator}/bin/terminator -x";
            }
            .${config.setup.terminal.emulator};

          "$fileManager" =
            if cfgTT.yazi then
              "$launchPrefix $launchInTerminal ${config.programs.yazi.package}/bin/yazi"
            else
              abort "Please enable a file manager";

          input = {
            kb_layout = "gb";
            kb_options = "caps:escape, compose:menu";
            numlock_by_default = true;

            # Hovering over a window won't focus it until you click
            follow_mouse = 2;
            float_switch_override_focus = 0;
          };

          "input:touchpad" = {
            middle_button_emulation = true; # Left and right click maps to middle click
            natural_scroll = true;
          };

          general = {
            gaps_in = 3;
            gaps_out = 5;

            layout = "dwindle";

            border_size = 2;
            resize_on_border = true;
            inherit (theme-colors) "col.active_border" "col.inactive_border";
          };

          dwindle.smart_split = true;

          ecosystem = {
            no_donation_nag = true;
            no_update_news = true;
          };

          decoration = {
            rounding = 5;

            dim_inactive = false;
          };

          # No anti-aliasing when zoomed in
          cursor.zoom_disable_aa = true;

          misc = {
            disable_hyprland_logo = true;
            force_default_wallpaper = 0;

            # If one window is fullscreen and another window is opened,
            # then disable fullscreen
            on_focus_under_fullscreen = 2;

            # Wait longer before saying "Application not responding"
            anr_missed_pings = 5;
          };

          binds.movefocus_cycles_fullscreen = true;

          animation = [
            "windows, 1, 1.5, overshot"
            "windowsOut, 1, 1.5, easeInOutQuart"
            "workspaces, 1, 1.5, easeInOutQuart"
            "zoomFactor, 1, 1.5, easeInOutQuart"
          ]
          ++ (lib.optional cfgB.animateGradientAngle.enable "borderangle, 1, ${
            toString (10 * cfgB.animateGradientAngle.speedSecs)
          }, linear, loop");

          bezier = [
            "linear, 0, 0, 1, 1"
            "easeInOutSine, 0.37, 0, 0.63, 1"
            "easeInOutQuad, 0.45, 0, 0.55, 1"
            "easeInOutCubic, 0.65, 0, 0.35, 1"
            "easeInOutQuart, 0.76, 0, 0.24, 1"
            "easeInOutQuint, 0.83, 0, 0.17, 1"
            "overshot, 0.05, 0.9, 0.1, 1.1"
          ];

          windowrule = [
            {
              name = "small-in-special-workspace";

              "match:workspace" = "s[1]";

              float = true;
              size = "(monitor_w*0.6) (monitor_h*0.6)";
              center = true;
            }
          ];

          bind =
            # General window management
            [
              "$mod, Q, killactive,"
              "$mod ALT, F, togglefloating,"
              ", F11, fullscreen, 2"
              "$mod, up, fullscreen, 1"
              "$mod SHIFT, up, fullscreen, 2"
              "$mod, X, fullscreen, 1"
              "$mod SHIFT, X, fullscreen, 2"
              "$mod, down, fullscreenstate, 0"
              "$mod, F12, exec, ${hypr-gamemode-sh}/bin/hypr-gamemode.sh"
            ]
            # Spawn new windows
            ++ [
              "$mod, T, exec, $launchPrefix $terminal"
              "$mod SHIFT, T, exec, [float; size 50% 50%] $launchPrefix $terminal"
              "$mod, E, exec, [float; size 50% 50%] $launchPrefix $fileManager"
            ]
            ++ lib.optional cfg.librewolf.enable "$mod, F, exec, $launchPrefix ${lib.getExe config.programs.librewolf.package}"
            ++ lib.optional cfg.misc.programs.anki "$mod, A, exec, $launchPrefix ${lib.getExe pkgs.anki}"
            ++ lib.optional cfg.misc.programs.obsidian "$mod, O, exec, $launchPrefix ${lib.getExe pkgs.obsidian}"
            ++ lib.optional cfg.terminal.tools.btop.enable "$mod, B, exec, $launchPrefix $launchInTerminal ${lib.getExe config.programs.btop.package}"
            ++ lib.optional osConfig.hardware.graphics.enable "$mod, G, exec, $launchPrefix ${lib.getExe pkgs.amdgpu_top} --gui"
            # Move focus
            ++ [
              "$mod, H, movefocus, l"
              "$mod, J, movefocus, d"
              "$mod, K, movefocus, u"
              "$mod, L, movefocus, r"
              "$mod, left, movefocus, l"
              "$mod, right, movefocus, r"
              "ALT, tab, cyclenext"
              "ALT SHIFT, tab, cyclenext, prev"
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
              builtins.concatLists (
                builtins.genList (
                  i:
                  let
                    workspace = toString (i + 1);
                    button = toString (lib.mod (i + 1) 10); # Button 0 for workspace 10
                  in
                  [
                    "$mod, ${button}, workspace, ${workspace}"
                    "$mod SHIFT, ${button}, movetoworkspace, ${workspace}"
                  ]
                ) 10
              )
            )
            # Move focus or window to special workspace
            ++ [
              "$mod, grave, togglespecialworkspace"
              "$mod SHIFT, grave, movetoworkspace, special"
            ]
            # Mute button
            ++ [
              ", Xf86AudioMute, exec, ${volume-adjust} mute"
              ", Xf86AudioPlay, exec, ${playerctl} play-pause"
              ", Xf86AudioPrev, exec, ${playerctl} previous"
              ", Xf86AudioNext, exec, ${playerctl} next"
            ]
            # Screenshots
            ++ [
              ", print, exec, ${hyprshot} -o ${downloads} -m region"
              "SHIFT, print, exec, ${hyprshot} -o ${downloads} -m window"
              "CTRL, print, exec, ${hyprshot} -o ${downloads} -m output -m active"
            ]
            # Zooming
            ++ [
              "$mod, equal, exec, ${zoom-change} ="
              "$mod SHIFT, equal, exec, ${zoom-change} +"
              "$mod, minus, exec, ${zoom-change} -"
            ]
            # This is absolutely bizarre and I don't understand it, but certain
            # programs like Dyson Sphere Program don't recognise middle click,
            # especially middle click drag, until I send them a completely empty
            # global shortcut like this. Unfathomable.
            ++ [
              "CTRL, grave, sendshortcut, ,, class:^(.*?)$"
            ];

          # Binds that repeat when held
          binde =
            # Volume controls
            [
              ", Xf86AudioRaiseVolume, exec, ${volume-adjust} .05+"
              ", Xf86AudioLowerVolume, exec, ${volume-adjust} .05-"
              "CTRL, up, exec, ${volume-adjust} .05+"
              "CTRL, down, exec, ${volume-adjust} .05-"
            ]
            # Brightness controls
            ++ [
              ", XF86MonBrightnessUp, exec, ${brightness-adjust} +5%"
              ", XF86MonBrightnessDown, exec, ${brightness-adjust} 5%-"
            ];

          # Mouse binds
          bindm = [
            "$mod, mouse:272, movewindow"
            "$mod, mouse:273, resizewindow"
          ];
        };
    };
  };
}
