{
  lib,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkMerge;

  osSetup = osConfig.setup;
in
{
  config = mkMerge [
    (mkIf true {
      setup.impermanence.keepDirs = [ "repos" ];
    })
    (mkIf osSetup.isGraphical {
      setup.impermanence.keepDirs = [ ".local/state/wireplumber" ];
    })
    (mkIf osSetup.openRGB.enable {
      setup.impermanence.keepDirs = [ ".config/OpenRGB" ];
    })
    (mkIf osSetup.virtManager.host.enable {
      setup.impermanence.keepDirs = [ "virt-manager" ];
    })
    (mkIf osSetup.virtualBox.host.enable {
      setup.impermanence.keepDirs = [ "VirtualBox VMs" ];
    })
    (mkIf osSetup.secrets.cachix.enable {
      setup.impermanence.keepFiles = [ ".config/cachix/cachix.dhall" ];
    })
    (mkIf osConfig.virtualisation.waydroid.enable {
      setup.impermanence.keepDirs = [ ".local/share/waydroid" ];
    })
  ];
}
