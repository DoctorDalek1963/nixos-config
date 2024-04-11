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

  inherit (config.consts.lib) optItemList;
in {
  home.packages =
    optItemList mt.git-all git-all
    ++ optItemList mt.just pkgs.just
    ++ optItemList mt.pre-commit pkgs.pre-commit;

  programs = {
    direnv = {
      enable = mt.direnv;
      nix-direnv.enable = mt.direnv;

      enableBashIntegration = config.setup.shells.bash;
    };

    gh = {
      enable = mt.gh;
      settings = {
        git_protocol = "ssh";
        editor = config.consts.nvim.path;
        prompt = "enabled";
        pager = "${pkgs.delta}/bin/delta";
      };
    };
  };
}
