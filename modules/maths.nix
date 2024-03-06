{pkgs, ...}: let
  customPython =
    pkgs.python3.withPackages
    (ps:
      with ps; [
        ipython
        jedi
        matplotlib
        numpy
        sympy
      ]);
  customTexlive =
    pkgs.texlive.combine
    {inherit (pkgs.texlive) scheme-medium;};
in {
  home.packages = with pkgs; [
    customPython

    # Sage math
    sageWithDoc

    customTexlive

    # GUI TikZ editor
    tikzit
  ];
}
