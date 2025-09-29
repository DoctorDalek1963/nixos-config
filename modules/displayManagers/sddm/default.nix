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
  ];
}
