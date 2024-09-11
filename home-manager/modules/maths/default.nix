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
  imports = [./octave.nix ./sage.nix];

  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optional cfg.lintrans inputs.lintrans.packages."${system}".default
      ++ lib.optional cfg.tikzit pkgs.tikzit
      ++ lib.optional cfg.weylus pkgs.weylus
      ++ lib.optional cfg.zotero pkgs.zotero;

    setup.impermanence = {
      keepDirs =
        [".cache/mathlib"] # Mathlib for Lean 4, which I only use in devShells
        ++ lib.optional cfg.lintrans ".lintrans"
        ++ lib.optionals cfg.zotero [".zotero/zotero" "Zotero"];
    };
  };
}
