{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.maths;
  inherit (config.consts.lib) optItemList;
in {
  imports = [./sage.nix];

  config = lib.mkIf cfg.enable {
    home.packages =
      optItemList cfg.tikzit pkgs.tikzit
      ++ (
        if cfg.texlive.enable
        then [cfg.texlive.pkg]
        else []
      );
  };
}
