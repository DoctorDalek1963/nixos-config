{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.misc.programs.obsidian {
    home.packages = [pkgs.obsidian];

    setup = {
      impermanence.keepDirs = ["Obsidian" ".config/obsidian"];
      terminal.shellAliases = lib.mkIf config.setup.maths.enable {
        cdom = "cd ~/Obsidian/Maths";
      };
    };
  };
}
