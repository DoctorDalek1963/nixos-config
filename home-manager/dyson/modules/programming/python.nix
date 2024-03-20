{
  pkgs,
  lib,
  config,
  ...
}: let
  probcalc = pkgs.buildPythonPackage rec {
    pname = "probcalc";
    version = "0.5.0";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    };
  };
in {
  config = lib.mkIf config.setup.programming.python {
    home = {
      packages = [
        (pkgs.python3.withPackages
          (ps:
            with ps;
              [
                ipython
                jedi

                bitstring
                matplotlib
                numpy
                sympy
              ]
              ++ [probcalc]))
      ];
      file.".ipython/profile_default/ipython_config.py".source = ../../files/ipython_config.py;
    };
  };
}
