{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.misc.programs.ms-teams {
    home.packages = [pkgs.anki];
    setup.impermanence.keepDirs = [".local/share/Anki2"];
  };
}
