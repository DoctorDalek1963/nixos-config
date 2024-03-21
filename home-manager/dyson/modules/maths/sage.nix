{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.maths;
in {
  config = lib.mkIf (cfg.enable && cfg.sage) {
    home = {
      packages = [pkgs.sageWithDoc];
      file.".sage/init.sage".text =
        # python
        ''
          _ = var('a b c d s t u v y z')
          _ = var('k m n p q', domain=ZZ)
          del _

          f = function('f')(x)
          g = function('g')(x)
          h = function('h')(x)

          try:
              import numpy as np

              def rad2deg(x, /):
                  return np.rad2deg(float(x))

              def deg2rad(x, /):
                  return np.deg2rad(float(x))

          except ModuleNotFoundError:
              pass

          %display unicode_art
        '';
    };
  };
}
