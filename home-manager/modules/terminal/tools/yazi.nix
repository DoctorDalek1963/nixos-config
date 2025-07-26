{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.terminal;
in
{
  config = lib.mkIf cfg.tools.yazi {
    programs.yazi = {
      enable = true;
      enableBashIntegration = cfg.shells.bash;

      keymap.mgr.prepend_keymap = [
        {
          on = [
            "g"
            "r"
          ];
          run = "cd ~/repos";
          desc = "Go to the repos directory";
        }
        {
          on = [
            "g"
            "n"
          ];
          run = "cd /etc/nixos";
          desc = "Go to the NixOS directory";
        }
      ];

      settings = lib.mkMerge [
        (lib.mkIf true {
          mgr.show_hidden = true;
        })
        (lib.mkIf config.setup.misc.programs.vlc {
          open.prepend_rules = [
            {
              mime = "video/*";
              use = [
                "play"
                "reveal"
              ];
            }
          ];

          opener.play = [
            {
              run = ''${pkgs.vlc}/bin/vlc "$@"'';
              desc = "VLC";
              orphan = true;
            }
          ];
        })
      ];
    };

    setup.terminal.shellAliases.y = "${config.programs.yazi.package}/bin/yazi";
  };
}
