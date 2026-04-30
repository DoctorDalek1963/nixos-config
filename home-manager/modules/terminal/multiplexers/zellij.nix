{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.terminal;
in
{
  config = lib.mkIf (cfg.multiplexer == "zellij") {
    programs.zellij = {
      enable = true;
      enableBashIntegration = cfg.shells.bash;

      settings = {
        theme = if config.programs.noctalia-shell.enable then "noctalia" else "catppuccin-macchiato";
        theme_dir = lib.mkIf config.programs.noctalia-shell.enable "${config.xdg.configHome}/zellij/themes";

        default_mode = "locked";
        show_startup_tips = false;
        advanced_mouse_actions = false; # Multiple pane select
        mouse_hover_effects = false;

        layout_dir = "${config.xdg.configHome}/zellij/layouts";
      };
    };

    xdg.configFile = {
      "zellij/config.kdl".text =
        lib.mkAfter
          # kdl
          ''
            keybinds {
                normal {
                    bind "Alt x" { ToggleFocusFullscreen; }
                    bind "Alt q" { CloseFocus; }
                }

                // Even in locked mode, I want basic navigation
                locked {
                    bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
                    bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
                    bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                    bind "Alt k" "Alt Up" { MoveFocus "Up"; }

                    bind "Alt n" { NewPane; }
                    bind "Alt t" { NewTab; }
                    bind "Alt q" { CloseFocus; }

                    bind "Alt x" { ToggleFocusFullscreen; }

                    bind "Alt 1" { GoToTab 1; }
                    bind "Alt 2" { GoToTab 2; }
                    bind "Alt 3" { GoToTab 3; }
                    bind "Alt 4" { GoToTab 4; }
                    bind "Alt 5" { GoToTab 5; }
                    bind "Alt 6" { GoToTab 6; }
                    bind "Alt 7" { GoToTab 7; }
                    bind "Alt 8" { GoToTab 8; }
                    bind "Alt 9" { GoToTab 9; }
                }
            }
          '';

      "zellij/layouts/uni.kdl".text = ''
        layout {
            pane size=1 borderless=true {
                plugin location="tab-bar"
            }

            // We can't use edit="main.tex" because we need to run nvim through direnv to get chktex
            pane command="direnv" {
                args "exec" "." "nvim" "main.tex"
            }

            pane size=6 command="direnv" {
                args "exec" "." "just" "watch"
            }

            pane size=1 borderless=true {
                plugin location="status-bar"
            }
        }
      '';
    };

    setup = {
      terminal.shellAliases = {
        z = "${config.programs.zellij.package}/bin/zellij";
        zun = "${config.programs.zellij.package}/bin/zellij --layout ${config.xdg.configHome}/zellij/layouts/uni.kdl";
      };
      impermanence.keepDirs = [ ".cache/zellij" ];
    };
  };
}
