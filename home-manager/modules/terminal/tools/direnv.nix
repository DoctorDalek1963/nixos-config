{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.direnv {
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      enableBashIntegration = config.setup.terminal.shells.bash;
    };

    setup.impermanence.keepDirs = [".local/share/direnv"];
  };
}
