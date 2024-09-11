{
  pkgs,
  lib,
  config,
  ...
}: let
  git-all = pkgs.stdenv.mkDerivation {
    name = "git-all";
    propagatedBuildInputs = [(pkgs.python3.withPackages (p: [p.rich]))];
    dontUnpack = true;
    installPhase = "install -Dm755 ${../../../files/scripts/git_all.py} $out/bin/git-all";
  };
in {
  config = lib.mkIf config.setup.terminal.tools.git-all {
    home.packages = [git-all];

    setup.terminal.shellAliases = let
      git-all-bin = "${git-all}/bin/git-all";
    in {
      gstall = "${git-all-bin} status";
      gfall = "${git-all-bin} fetch";
      gplall = "${git-all-bin} pull";
      gfplall = "${git-all-bin} fetch && ${git-all-bin} pull";
      gpall = "${git-all-bin} push";
    };
  };
}
