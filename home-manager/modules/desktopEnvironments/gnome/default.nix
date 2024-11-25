# This config was heavily inspired by this article:
# https://hoverbear.org/blog/declarative-gnome-configuration-in-nixos/
{
  pkgs,
  lib,
  config,
  ...
}: {
  imports = [./dconf.nix ./extensions ./themes.nix];

  config = lib.mkIf config.setup.desktopEnvironments.gnome.enable {
    home.packages = [pkgs.gnome-tweaks];

    setup.impermanence.keepDirs = [
      ".local/share/keyrings"

      # GNOME Online Accounts
      ".config/goa-1.0"

      ".config/evolution/sources"
      ".cache/evolution"
    ];
  };
}
