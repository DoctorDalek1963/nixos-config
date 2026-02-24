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
        theme = "catppuccin-macchiato";
        default_mode = "locked";
        show_startup_tips = false;
        advanced_mouse_actions = false; # Multiple pane select

        layout_dir = "${config.xdg.configHome}/zellij/layouts";
        default_layout = "custom_default";
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

      # The original default layout but we default to a vertical split
      # instead of a horizontal one
      "zellij/layouts/custom_default.kdl".text = ''
        layout {
            pane size=1 borderless=true {
                plugin location="tab-bar"
            }
            pane split_direction="vertical"
            pane size=1 borderless=true {
                plugin location="status-bar"
            }
        }
      '';

      # This was generated with `zellij setup --dump-swap-layout default` and
      # then I swapped the vertical and horizontal tiled swap layouts
      "zellij/layouts/custom_default.swap.kdl".text = ''
        tab_template name="ui" {
           pane size=1 borderless=true {
               plugin location="tab-bar"
           }
           children
           pane size=1 borderless=true {
               plugin location="status-bar"
           }
        }

        swap_tiled_layout name="horizontal" {
            ui max_panes=5 {
                pane
                pane
            }
            ui max_panes=8 {
                pane {
                    pane split_direction="vertical" { children; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                }
            }
            ui max_panes=12 {
                pane {
                    pane split_direction="vertical" { children; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                    pane split_direction="vertical" { pane; pane; pane; pane; }
                }
            }
        }

        swap_tiled_layout name="vertical" {
            ui max_panes=5 {
                pane split_direction="vertical" {
                    pane
                    pane { children; }
                }
            }
            ui max_panes=8 {
                pane split_direction="vertical" {
                    pane { children; }
                    pane { pane; pane; pane; pane; }
                }
            }
            ui max_panes=12 {
                pane split_direction="vertical" {
                    pane { children; }
                    pane { pane; pane; pane; pane; }
                    pane { pane; pane; pane; pane; }
                }
            }
        }

        swap_tiled_layout name="stacked" {
            ui min_panes=5 {
                pane split_direction="vertical" {
                    pane
                    pane stacked=true { children; }
                }
            }
        }

        swap_floating_layout name="staggered" {
            floating_panes
        }

        swap_floating_layout name="enlarged" {
            floating_panes max_panes=10 {
                pane { x "5%"; y 1; width "90%"; height "90%"; }
                pane { x "5%"; y 2; width "90%"; height "90%"; }
                pane { x "5%"; y 3; width "90%"; height "90%"; }
                pane { x "5%"; y 4; width "90%"; height "90%"; }
                pane { x "5%"; y 5; width "90%"; height "90%"; }
                pane { x "5%"; y 6; width "90%"; height "90%"; }
                pane { x "5%"; y 7; width "90%"; height "90%"; }
                pane { x "5%"; y 8; width "90%"; height "90%"; }
                pane { x "5%"; y 9; width "90%"; height "90%"; }
                pane focus=true { x 10; y 10; width "90%"; height "90%"; }
            }
        }

        swap_floating_layout name="spread" {
            floating_panes max_panes=1 {
                pane {y "50%"; x "50%"; }
            }
            floating_panes max_panes=2 {
                pane { x "1%"; y "25%"; width "45%"; }
                pane { x "50%"; y "25%"; width "45%"; }
            }
            floating_panes max_panes=3 {
                pane focus=true { y "55%"; width "45%"; height "45%"; }
                pane { x "1%"; y "1%"; width "45%"; }
                pane { x "50%"; y "1%"; width "45%"; }
            }
            floating_panes max_panes=4 {
                pane { x "1%"; y "55%"; width "45%"; height "45%"; }
                pane focus=true { x "50%"; y "55%"; width "45%"; height "45%"; }
                pane { x "1%"; y "1%"; width "45%"; height "45%"; }
                pane { x "50%"; y "1%"; width "45%"; height "45%"; }
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
