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

    customTexlive

    # Uni notes
    obsidian

    # Sage math
    sageWithDoc

    # GUI TikZ editor
    tikzit
  ];
}
