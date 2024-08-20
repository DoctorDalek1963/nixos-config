{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.terminal.tools.tldr {
    home.packages = [pkgs.tldr];

    setup.impermanence.keepDirs = [".tldrc"];
  };
}
