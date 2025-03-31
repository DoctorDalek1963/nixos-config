{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.fonts;

  nerdfontFonts =
    ["Arimo"]
    ++ lib.optional cfg.hackNerdFont "Hack";
in {
  fonts.fontconfig.enable = true;

  home.packages =
    lib.optional ((builtins.length nerdfontFonts) > 0) (pkgs.nerdfonts.override {fonts = nerdfontFonts;})
    ++ lib.optionals cfg.microsoftFonts [pkgs.corefonts pkgs.vistafonts];
}
