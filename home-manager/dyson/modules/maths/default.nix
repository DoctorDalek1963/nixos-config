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
        if builtins.isNull cfg.texlive
        then []
        else [cfg.texlive]
      );
  };
}
