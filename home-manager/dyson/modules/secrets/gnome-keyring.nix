{pkgs, ...}: {
  home.packages = with pkgs.gnome; [
    gnome-keyring
  ];

  services.gnome-keyring = {
    enable = true;
    components = ["ssh"];
  };

  # TODO: Can I make a systemd service to populate gnome-keyring automatically
  # using the passphrases provided by sops?
}
