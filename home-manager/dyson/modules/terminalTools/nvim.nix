{
  lib,
  config,
  ...
}: let
  inherit (config.consts) nvim;
in {
  config = lib.mkIf config.setup.terminalTools.nvimCustom {
    home = {
      packages = [nvim.pkg];
      sessionVariables.EDITOR = nvim.path;
    };
  };
}
