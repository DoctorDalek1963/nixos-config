{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.office;
in
{
  setup.fonts.microsoftFonts = lib.mkIf (cfg.libreoffice || cfg.onlyoffice) (lib.mkDefault true);

  home.packages =
    lib.optional cfg.libreoffice pkgs.libreoffice
    ++ lib.optional cfg.onlyoffice pkgs.onlyoffice-desktopeditors;
}
