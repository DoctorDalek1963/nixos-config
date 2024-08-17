{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.delta {
    home.packages = [pkgs.delta];
  };
}
