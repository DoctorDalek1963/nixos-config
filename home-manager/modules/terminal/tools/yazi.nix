{
  lib,
  config,
  ...
}: let
  cfg = config.setup.terminal;
in {
  config = lib.mkIf cfg.tools.yazi {
    programs.yazi = {
      enable = true;
      enableBashIntegration = cfg.shells.bash;
    };

    setup.terminal.shellAliases.y = "${config.programs.yazi.package}/bin/yazi";
  };
}
