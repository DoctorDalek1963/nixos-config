{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.fzf {
    programs.fzf = {
      enable = true;
      # TODO: Config colours
      enableBashIntegration = config.setup.terminal.shells.bash;
    };
  };
}
