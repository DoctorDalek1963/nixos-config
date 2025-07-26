{
  lib,
  config,
  osConfig,
  ...
}:
let
  cfg = config.setup.terminal;

  color-scheme =
    {
      "catppuccin-macchiato" = "Catppuccin Macchiato";
      "onedark" = "One Dark (Gogh)";
    }
    ."${cfg.theme}";

  cursor-theme =
    {
      "catppuccin-macchiato" = "catppuccin-macchiato-light-cursors";
    }
    ."${cfg.theme}";

  default-cursor-style = if osConfig.setup.isLaptop then "SteadyBlock" else "BlinkingBlock";
in
{
  config = lib.mkIf (cfg.emulator == "wezterm") {
    programs.wezterm = {
      enable = true;
      enableBashIntegration = cfg.shells.bash;

      extraConfig =
        # lua
        ''
          local act = wezterm.action

          config = {
            font = wezterm.font('Hack Nerd Font Mono'),
            font_size = 10,

            color_scheme = '${color-scheme}',

            bold_brightens_ansi_colors = "BrightAndBold",
            check_for_updates = false,

            cursor_blink_ease_in = 'Constant',
            cursor_blink_ease_out = 'Constant',
            cursor_blink_rate = 650,
            default_cursor_style = '${default-cursor-style}',
            xcursor_theme = "${cursor-theme}";

            enable_scroll_bar = false,

            hide_mouse_cursor_when_typing = true,
            hide_tab_bar_if_only_one_tab = true,

            keys = {
              { key = 'F11', action = act.ToggleFullScreen },
              { key = 'Enter', mods = 'ALT', action = act.DisableDefaultAssignment },

              -- Zellij can't pick up two modifiers in one keybind for some reason
              { key = 'x', mods = 'CTRL|SHIFT', action = act.SendKey {key = 'x', mods = 'ALT'} }
            },

            scrollback_lines = 7500,
            skip_close_confirmation_for_processes_named = {
              'sh', 'bash', 'zsh', 'fish', 'elvish', 'nu', 'tmux', 'zellij'
            },

            visual_bell = {
              fade_in_duration_ms = 80,
              fade_out_duration_ms = 80,
              fade_in_function = 'Ease',
              fade_out_function = 'Ease',
            },
          }

          -- Start in fullscreen
          if os.getenv("XDG_CURRENT_DESKTOP") == "Hyprland" then
            config.window_background_opacity = 0.9
          else
            wezterm.on("gui-startup", function()
              local tab, pane, window = wezterm.mux.spawn_window{}
              window:gui_window():toggle_fullscreen()
            end)
          end

          return config
        '';
    };
  };
}
