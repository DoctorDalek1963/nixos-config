{
  lib,
  config,
  ...
}: let
  inherit (config.setup.desktopEnvironments) background;

  background-path =
    if builtins.isPath background
    then background
    else background.light;
in {
  config = lib.mkIf config.setup.desktopEnvironments.cinnamon.enable {
    dconf = {
      enable = true;
      settings = {
        "org/cinnamon/desktop/background" = {
          picture-uri = "file://${background-path}";
        };
      };
    };
  };
}
