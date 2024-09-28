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
