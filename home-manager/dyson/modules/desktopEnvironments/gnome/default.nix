# This config was heavily inspired by this article:
# https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./dconf.nix ./extensions/default.nix];

  config = lib.mkIf config.setup.desktopEnvironments.gnome.enable {
    home.packages = with pkgs; [
      gnome.gnome-tweaks
      terminator
    ];

    xdg.configFile."terminator/config".source = ../../../files/terminator_config;

    dconf.enable = true;

    gtk = {
      enable = true;

      gtk3.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };

      gtk4.extraConfig = {
        Settings = ''
          gtk-application-prefer-dark-theme=1
        '';
      };
    };
  };
}
