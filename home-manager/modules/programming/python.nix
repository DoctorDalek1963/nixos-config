{
  pkgs,
  lib,
  config,
  ...
}:
let
  probcalc = pkgs.python3.pkgs.buildPythonPackage rec {
    pname = "probcalc";
    version = "0.5.0";

    src = pkgs.fetchPypi {
      inherit pname version;
      sha256 = "sha256-5k4PXB2DY98/BukWML/o1BX8M8kb0hwHXpBqUeL4AbU=";
    };

    pyproject = true;
    build-system = [ pkgs.python3.pkgs.setuptools ];
  };

  python = pkgs.python3.withPackages (
    ps:
    (with ps; [
      ipython
      jedi
      jupyter

      bitstring
      matplotlib
      networkx
      numpy
      pandas
      scikit-learn
      scipy
      sympy
    ])
    ++ [ probcalc ]
  );

  python-bin = "${python}/bin/python";
in
{
  config = lib.mkIf config.setup.programming.python {
    home = {
      packages = [ python ];
      file = {
        ".ipython/profile_default/ipython_config.py".text =
          # python
          ''
            c.InteractiveShell.confirm_exit = False
            c.InteractiveShell.autocall = 1
            c.InteractiveShell.colors = "Linux"

            c.InteractiveShellApp.exec_lines = [
                "%load_ext autoreload",
                "%autoreload 2",
                """
            import itertools
            import operator
            import os
            import re
            import sys
            import time

            from datetime import datetime as dt
            from datetime import timedelta as td

            import math as ma

            import matplotlib as mpl
            import matplotlib.pyplot as plt

            import numpy as np
            from numpy import linalg as la

            import pandas as pd

            import scipy

            import sympy as sp

            import networkx as nx

            import bitstring

            from probcalc import *

            a, b, c, d, i, j, l, r, t, u, v, w, x, y, z = sp.symbols("a b c d i j l r t u v w x y z")
            k, m, n, p, q = sp.symbols("k m n p q", integer=True)
            f, g, h = sp.symbols("f g h", cls=sp.Function)
            sp.init_printing()

            def matrix_minors(matrix: sp.Matrix) -> sp.Matrix:
                return sp.Matrix([
                    [matrix.minor(row, col) for col in range(matrix.T.rows)]
                    for row in range(matrix.rows)
                ])

            def get_bits(*args, **kwargs) -> str:
                return bitstring.BitArray(*args, **kwargs).bin
            """,
            ]
          '';
        ".jupyter/jupyter_lab_config.py".text =
          # python
          ''
            c = get_config()

            # Disallow installation of other packages
            c.LabApp.extension_manager = "readonly"

            # Allow connections from other devices on Tailnet as if they were
            # local (so they don't need to authenticate)
            c.ServerApp.ip = "0.0.0.0"
            c.ServerApp.local_hostnames = ["localhost", "100.*.*.*"]
          '';
        ".jupyter/jupyter_notebook_config.py".text =
          # python
          ''
            c = get_config()

            # Allow connections from other devices on Tailnet as if they were
            # local (so they don't need to authenticate)
            c.ServerApp.ip = "0.0.0.0"
            c.ServerApp.local_hostnames = ["localhost", "100.*.*.*"]
          '';
      };
    };

    setup = {
      impermanence.keepFiles = [
        ".python_history"
        ".ipython/profile_default/history.sqlite"
      ];

      terminal.shellAliases = {
        p = "python";
        ipy = "${python-bin} -m IPython";
        jlb = "${python-bin} -m jupyter lab";
        jnb = "${python-bin} -m jupyter notebook";
        pmhttp = "${python-bin} -m http.server";
      };
    };
  };
}
