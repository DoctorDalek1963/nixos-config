{
  lib,
  config,
  osConfig,
  ...
}: let
  cfg = config.setup.desktopEnvironments;

  background-settings =
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
in {
  config = lib.mkIf osConfig.setup.desktopEnvironments.cinnamon.enable {
    assertions = [
      {
        assertion = cfg.background-slideshow-path != null || cfg.background != null;
        message = "Cinnamon requires either a background or a background slideshow path";
      }
    ];

    dconf = {
      enable = true;
      settings =
        {
          # Maximize window when dragging to top instead of tiling to top half
          "org/cinnamon/muffin".tile-maximize = true;
        }
        // background-settings;
    };
  };
}
