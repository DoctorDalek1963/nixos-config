{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.misc.programs.mediaCuration {
    home.packages = with pkgs; [
      gimp3
      imagemagick
      jellyfin-ffmpeg
      kdePackages.kdenlive
      inkscape
    ];

    setup.terminal.shellAliases = {
      # I don't want to manage yet another flake input
      m4b-tool = "nix run github:sandreas/m4b-tool#m4b-tool-libfdk";
    };
  };
}
