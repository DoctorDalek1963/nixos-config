{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminalTools.delta {
    home.packages = [pkgs.delta];
    # TODO: Configure defaults for delta
  };
}
