{
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.terminal.tools.lazygit {
    programs.lazygit = {
      enable = true;
      settings = {
        gui.nerdFontsVersion = "3";
        update.method = "never";
        os = {
          edit = "${config.setup.shared.nvim.path} {{filename}}";
          editInTerminal = true;
        };
      };
    };

    setup = {
      terminal.shellAliases.lg = "${config.programs.lazygit.package}/bin/lazygit";
      impermanence.keepFiles = [ ".local/state/lazygit/state.yml" ];
    };
  };
}
