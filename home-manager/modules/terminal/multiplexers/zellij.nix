{
  lib,
  config,
  ...
}: let
  cfg = config.setup.terminal;
in {
  config = lib.mkIf (cfg.multiplexer == "zellij") {
    programs.zellij = {
      enable = true;
      enableBashIntegration = cfg.shells.bash;

      settings = {
        theme = "catppuccin-macchiato";
        default_mode = "locked";
      };
    };

    xdg.configFile."zellij/config.kdl".text =
      lib.mkAfter
      # kdl
      ''
        keybinds {
            normal {
                // I'd love to use "Ctrl Shift x" here, but Zellij doesn't seem
                // to understand that. I'm currently remapping Ctrl+Shift+x to
                // Alt+x in WezTerm, which gets picked up here. This method frees
                // up Ctrl+x for other things, but also allows Alt+x, which I
                // previously never used anyway.
                bind "Alt x" { ToggleFocusFullscreen; }
            }

            // Even in locked mode, I want basic navigation
            locked {
                bind "Alt h" "Alt Left" { MoveFocusOrTab "Left"; }
                bind "Alt l" "Alt Right" { MoveFocusOrTab "Right"; }
                bind "Alt j" "Alt Down" { MoveFocus "Down"; }
                bind "Alt k" "Alt Up" { MoveFocus "Up"; }

                bind "Alt n" { NewPane; }

                // See "Alt x" in normal block
                bind "Alt x" { ToggleFocusFullscreen; }
            }
        }
      '';

    setup.terminal.shellAliases.z = "${config.programs.zellij.package}/bin/zellij";
  };
}
