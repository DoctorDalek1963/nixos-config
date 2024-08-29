{
  lib,
  config,
  ...
}: let
  cfg = config.setup.desktopEnvironments;
in {
  config = lib.mkIf cfg.cinnamon.enable {
    assertions = [
      {
        assertion = cfg.background-slideshow-path != null || cfg.background != null;
        message = "Cinnamon requires either a background or a background slideshow path";
      }
    ];

    dconf = {
      enable = true;
      settings =
        if cfg.background-slideshow-path != null
        then {
          "org/cinnamon/desktop/background/slideshow" = {
            slideshow-enabled = true;
            image-source = "directory://${cfg.background-slideshow-path}";
          };
        }
        else {
          "org/cinnamon/desktop/background" = {
            picture-uri = "file://${
              if builtins.isPath cfg.background
              then cfg.background
              else cfg.background.light
            }";
          };
          "org/cinnamon/desktop/background/slideshow" = {
            slideshow-enabled = false;
          };
        };
    };
  };
}
