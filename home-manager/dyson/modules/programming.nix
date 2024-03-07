{pkgs, ...}: {
  home = {
    packages = with pkgs; [
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
    ];

    sessionVariables.GCC_COLORS = "error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01";

    file = {
      ".cargo/clippy.conf".source = ../files/clippy.conf;
      ".cargo/config.toml".source = ../files/cargo-config.toml;
    };
  };
}
