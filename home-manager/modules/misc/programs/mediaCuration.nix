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
    ];
  };
}
