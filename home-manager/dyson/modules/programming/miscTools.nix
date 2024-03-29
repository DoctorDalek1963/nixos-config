{
  pkgs,
  config,
  ...
}: let
  git-all = pkgs.stdenv.mkDerivation {
    name = "git-all";
    propagatedBuildInputs = [(pkgs.python3.withPackages (p: [p.rich]))];
    dontUnpack = true;
    installPhase = "install -Dm755 ${../../files/scripts/git_all.py} $out/bin/git-all";
  };

  mt = config.setup.programming.miscTools;

  optItemList = opt: item:
    if opt
    then [item]
    else [];
in {
  home.packages =
    optItemList mt.git-all git-all
    ++ optItemList mt.just pkgs.just
    ++ optItemList mt.pre-commit pkgs.pre-commit;

  programs.gh = {
    enable = mt.gh;
    settings = {
      git_protocol = "ssh";
      editor = config.consts.nvim.path;
      prompt = "enabled";
      pager = "${pkgs.delta}/bin/delta";
    };
  };
}
