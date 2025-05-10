{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.fonts;

  nerdfontFonts =
    [pkgs.nerd-fonts.arimo]
    ++ lib.optional cfg.hackNerdFont pkgs.nerd-fonts.hack;
in {
  fonts.fontconfig.enable = true;

  home.packages =
    nerdfontFonts
    ++ lib.optionals cfg.microsoftFonts [pkgs.corefonts pkgs.vistafonts];
}
