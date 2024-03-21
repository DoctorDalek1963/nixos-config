{
  pkgs,
  lib,
  config,
  ...
}: let
  gnome-keyring-enabled = config.setup.secrets && config.setup.desktopEnvironments.gnome.enable;
in {
  config = lib.mkIf gnome-keyring-enabled {
    home.packages = with pkgs.gnome; [
      gnome-keyring
    ];

    services.gnome-keyring = {
      enable = gnome-keyring-enabled;
      components = ["ssh"];
    };

    # TODO: Can I make a systemd service to populate gnome-keyring automatically
    # using the passphrases provided by sops?
  };
}
