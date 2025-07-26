{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.displayManagers.sddm;
in
{
  config = lib.mkMerge [
    (lib.mkIf cfg.enable {
      services.displayManager.sddm.enable = true;
      setup.impermanence.keepFiles = [ "/var/lib/sddm/state.conf" ];
    })
    (lib.mkIf (cfg.enable && cfg.theme == "catppuccin-macchiato") {
      services.displayManager.sddm = {
        theme = "catppuccin-macchiato";
        package = pkgs.kdePackages.sddm; # This theme needs Qt6
      };

      environment.systemPackages = [
        (
          (pkgs.catppuccin-sddm.override {
            flavor = "macchiato";
          }).overrideAttrs
          {
            patches = [ ./themes/catppuccin-sddm-custom.patch ];
          }
        )
      ];
    })
    (lib.mkIf (cfg.enable && cfg.theme == "sugar-light-nixos-simple-blue") {
      services.displayManager.sddm =
        let
          theme-pkg = (pkgs.callPackage ./themes/sugar-light.nix { }) {
            background = ../../../home-manager/files/desktop-backgrounds/nixos-simple-blue.png;
          };
        in
        {
          theme = "${theme-pkg}";
          package = pkgs.plasma5Packages.sddm; # This theme needs Qt5
        };
    })
  ];
}
