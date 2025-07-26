{
  lib,
  config,
  ...
}:
let
  cfg = config.setup.terminal;
in
{
  config = lib.mkIf cfg.tools.zoxide {
    programs.zoxide = {
      enable = true;
      options = [
        "--cmd"
        "cd"
      ];

      enableBashIntegration = cfg.shells.bash;
    };

    setup.impermanence.keepDirs = [ ".local/share/zoxide" ];
  };
}
