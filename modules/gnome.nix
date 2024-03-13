{pkgs, ...}: {
  # Enable minimal GNOME system-wide
  services.xserver = {
    displayManager.gdm.enable = true;
    desktopManager.gnome.enable = true;
  };

  programs.dconf.enable = true;

  # Get rid of all the chaff
  environment.gnome.excludePackages =
    (with pkgs; [
      gnome-photos
      gnome-tour
    ])
    ++ (with pkgs.gnome; [
      atomix # Puzzle game
      cheese # WEBCAM tool
      epiphany # Web browser
      file-roller # Zip archive manager
      geary # Email reader
      gedit # Text editor
      gnome-characters
      gnome-contacts
      gnome-initial-setup
      gnome-music
      hitori # Sudoku game
      iagno # Go game
      tali # Poker game
      yelp # Help view
    ]);
}
