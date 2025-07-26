{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.misc.programs.ms-teams {
    home.packages = [ pkgs.teams-for-linux ];

    setup = {
      impermanence.keepDirs = [ ".config/teams-for-linux" ];
      fonts.microsoftFonts = true;
    };
  };
}
