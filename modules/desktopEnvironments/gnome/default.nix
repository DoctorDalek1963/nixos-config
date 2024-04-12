{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup.desktopEnvironments.gnome;

  chaff =
    (with pkgs; [
      gedit # Text editor
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      atomix # Puzzle game
      cheese # Webcam tool
      epiphany # Web browser
      file-roller # Zip archive manager
      geary # Email reader
      gnome-contacts
      gnome-initial-setup
      gnome-music
      hitori # Sudoku game
      iagno # Go game
      tali # Poker game
      totem # Video player
      yelp # Help view
    ]);
in {
  imports = [./profile-pictures.nix];

  config = lib.mkIf cfg.enable {
    services.xserver.desktopManager.gnome.enable = cfg.enable;

    programs.dconf.enable = cfg.enable;

    # Get rid of all the chaff
    environment.gnome.excludePackages =
      if (cfg.enable && cfg.minimal)
      then chaff
      else [];
  };
}
