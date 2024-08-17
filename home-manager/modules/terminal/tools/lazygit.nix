{
  lib,
  config,
  ...
}: let
  inherit (config.consts) nvimPath;
in {
  config = lib.mkIf config.setup.terminal.tools.lazygit {
    programs.lazygit = {
      enable = true;
      settings = {
        gui.nerdFontsVersion = "3";
        update.method = "never";
        os = {
          edit = "${nvimPath} {{filename}}";
          editInTerminal = true;
        };
      };
    };

    setup.terminal.shellAliases.lg = "${config.programs.lazygit.package}/bin/lazygit";
  };
}
