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

      config.global.hide_env_diff = true;
    };

    setup = {
      impermanence.keepDirs = [".local/share/direnv"];

      terminal.shellAliases.ndr = "nix-direnv-reload";
    };
  };
}
