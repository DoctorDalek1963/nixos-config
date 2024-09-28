{
  pkgs,
  lib,
  config,
  ...
}: let
  probcalc = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "probcalc";
    version = "0.5.0";
    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-5k4PXB2DY98/BukWML/o1BX8M8kb0hwHXpBqUeL4AbU=";
    };
  };

  python =
    pkgs.python3.withPackages
    (ps:
      (with ps; [
        ipython
        jedi
        jupyter

        bitstring
        matplotlib
        numpy
        pandas
        scipy
        sympy
      ])
      ++ [probcalc]);

  python-bin = "${python}/bin/python";
in {
  config = lib.mkIf config.setup.programming.python {
    home = {
      packages = [python];
      file.".ipython/profile_default/ipython_config.py".source = ../../files/ipython_config.py;
    };

    setup = {
      impermanence.keepFiles = [
        ".python_history"
        ".ipython/profile_default/history.sqlite"
      ];

      terminal.shellAliases = {
        p = "python";
        ipy = "${python-bin} -m IPython";
        jnb = "${python-bin} -m jupyter notebook";
        pmhttp = "${python-bin} -m http.server";
      };
    };
  };
}
