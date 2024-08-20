{
  pkgs,
  lib,
  config,
  system,
  inputs,
  ...
}: let
  cfg = config.setup.maths;
in {
  imports = [./sage.nix];

  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optional cfg.lintrans inputs.lintrans.packages."${system}".default
      ++ lib.optional cfg.octave pkgs.octaveFull
      ++ lib.optional cfg.tikzit pkgs.tikzit
      ++ lib.optional cfg.weylus pkgs.weylus
      ++ lib.optional cfg.zotero pkgs.zotero;

    setup.impermanence = {
      keepFiles = lib.optional cfg.octave ".local/share/octave/history";

      keepDirs =
        [".cache/mathlib"] # Mathlib for Lean 4, which I only use in devShells
        ++ lib.optional cfg.lintrans ".lintrans"
        ++ lib.optionals cfg.zotero [".zotero/zotero" "Zotero"];
    };
  };
}
