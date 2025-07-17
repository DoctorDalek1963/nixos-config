{
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.ripgrep {
    programs.ripgrep = {
      enable = true;
      arguments = [
        "--max-columns=150"
        "--max-columns-preview"
        "--glob=!.git/*"
        "--smart-case"
      ];
    };

    # Search long-form history
    setup.terminal.shellAliases = {
      # TODO: Make history file shell-agnostic
      rghist = "cat ${config.home.homeDirectory}/.bash_history | ${config.programs.ripgrep.package}/bin/rg --";
    };
  };
}
