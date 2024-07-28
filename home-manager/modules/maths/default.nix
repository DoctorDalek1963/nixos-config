{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.maths;
in {
  imports = [./sage.nix];

  config = lib.mkIf cfg.enable {
    home.packages =
      lib.optional cfg.octave pkgs.octaveFull
      ++ lib.optional cfg.tikzit pkgs.tikzit
      ++ lib.optional cfg.zotero pkgs.zotero;
  };
}
