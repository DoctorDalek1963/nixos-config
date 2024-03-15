{
  pkgs,
  my-nixvim,
  ...
}: let
  git-all = pkgs.stdenv.mkDerivation {
    name = "git-all";
    propagatedBuildInputs = [(pkgs.python3.withPackages (p: [p.rich]))];
    dontUnpack = true;
    installPhase = "install -Dm755 ${../files/scripts/git_all.py} $out/bin/git-all";
  };
in {
  home = {
    packages =
      (with pkgs; [
        # Build tools & automation
        just
        pre-commit

        # Haskell
        ghc

        # Nix
        alejandra
        deadnix
        statix

        # Rust
        rustup
      ])
      ++ [git-all];

    sessionVariables.GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";

    file = {
      ".cargo/clippy.conf".source = ../files/clippy.conf;
      ".cargo/config.toml".source = ../files/cargo-config.toml;
    };
  };

  programs.gh = {
    enable = true;
    settings = {
      git_protocol = "ssh";
      editor = "${my-nixvim}/bin/nvim";
      prompt = "enabled";
      pager = "${pkgs.delta}/bin/delta";
    };
  };
}
