{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.misc {
    home.packages = [pkgs.devtoolbox];
  };
}
