{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.misc.programs.loupe {
    home.packages = [pkgs.loupe];

    xdg.mimeApps = {
      enable = true;
      defaultApplications = {
        "image/*" = ["org.gnome.Loupe.desktop"];
      };
    };
  };
}
