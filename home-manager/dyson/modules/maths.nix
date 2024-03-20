{pkgs, ...}: let
  customTexlive =
    pkgs.texlive.combine
    {inherit (pkgs.texlive) scheme-medium;};
in {
  home.packages = with pkgs; [
    customTexlive

    # Sage math
    sageWithDoc

    # GUI TikZ editor
    tikzit
  ];
}
