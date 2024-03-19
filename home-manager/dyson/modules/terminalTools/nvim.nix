{
  lib,
  config,
  my-nixvim,
  ...
}: {
  config = lib.mkIf config.setup.terminalTools.nvim {
    home = {
      packages = [my-nixvim];
      sessionVariables.EDITOR = "${my-nixvim}/bin/nvim";
    };
  };
}
