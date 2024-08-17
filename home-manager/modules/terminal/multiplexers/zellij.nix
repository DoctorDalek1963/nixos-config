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
                // I'd love to use "Ctrl Shift x" here, but Zellij doesn't seem
                // to understand that. I'm currently remapping Ctrl+Shift+x to
                // Alt+x in WezTerm, which gets picked up here. This method frees
                // up Ctrl+x for other things, but also allows Alt+x, which I
                // previously never used anyway.
                bind "Alt x" { ToggleFocusFullscreen; }
            }
        }
      '';

    setup.terminal.shellAliases.z = "${config.programs.zellij.package}/bin/zellij";
  };
}
