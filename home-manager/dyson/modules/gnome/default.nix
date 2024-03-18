# This config was heavily inspired by this article:
# https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
{pkgs, ...}: {
  imports = [./dconf.nix ./extensions/default.nix];

  home.packages = with pkgs; [
    gnome.gnome-tweaks
    terminator
  ];

  xdg.configFile."terminator/config".source = ../../files/terminator_config;

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
}
