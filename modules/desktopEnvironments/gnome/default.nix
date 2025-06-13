{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.desktopEnvironments.gnome;

  chaff = with pkgs; [
    atomix # Puzzle game
    cheese # Webcam tool
    epiphany # Web browser
    file-roller # Zip archive manager
    geary # Email reader
    gedit # Text editor
    gnome-connections
    gnome-contacts
    gnome-initial-setup
    gnome-music
    gnome-photos
    gnome-tour
    hitori # Sudoku game
    iagno # Go game
    tali # Poker game
    totem # Video player
    yelp # Help view
  ];
in {
  config = lib.mkIf cfg.enable {
    services.desktopManager.gnome.enable = cfg.enable;

    programs.dconf.enable = cfg.enable;

    # Get rid of all the chaff
    environment.gnome.excludePackages =
      if (cfg.enable && cfg.minimal)
      then chaff
      else [];
  };
}
