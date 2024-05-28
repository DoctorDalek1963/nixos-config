{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminalTools.fzf {
    programs.fzf = {
      enable = true;
      # TODO: Config colours
      enableBashIntegration = config.setup.shells.bash;
    };
  };
}
