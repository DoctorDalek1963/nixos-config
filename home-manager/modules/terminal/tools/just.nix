{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.just {
    home.packages = [pkgs.just];
    setup.terminal.shellAliases.j = "just";
  };
}
