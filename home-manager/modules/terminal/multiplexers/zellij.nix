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
      };
    };

    xdg.configFile."zellij/config.kdl".text =
      lib.mkAfter
      # kdl
      ''
        keybinds {
            normal {
                // I'd love to use "Ctrl Shift x" or "Ctrl X" here, but Zellij
                // doesn't seem to understand that. This current method allows
                // both Ctrl+x and Ctrl+Shift+x, which is suboptimal, but good
                // enough for now.
                bind "Ctrl x" { ToggleFocusFullscreen; }
            }
        }
      '';
  };
}
