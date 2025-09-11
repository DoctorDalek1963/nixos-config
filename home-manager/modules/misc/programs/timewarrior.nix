{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.misc.programs.timewarrior {
    home.packages = [ pkgs.timewarrior ];

    setup.impermanence.keepDirs = [
      ".config/timewarrior"
      ".local/share/timewarrior"
    ];
  };
}
