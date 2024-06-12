{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.fonts;
in {
  fonts.fontconfig.enable = true;

  home.packages =
    lib.optional cfg.hackNerdFont (pkgs.nerdfonts.override {fonts = ["Hack"];})
    ++ lib.optionals cfg.microsoftFonts [pkgs.corefonts pkgs.vistafonts];
}
