{
  lib,
  # config,
  osConfig,
  ...
}:
let
  inherit (lib) mkIf mkMerge;

  osSetup = osConfig.setup;
  cfgGaming = osSetup.gaming;
in
{
  config = mkMerge [
    (mkIf true {
      setup.impermanence.keepDirs = [ "repos" ];
    })
    (mkIf cfgGaming.enable {
      setup.impermanence.keepDirs = [
        "Games"
        ".config/ludusavi"
      ];
    })
    (mkIf (cfgGaming.enable && cfgGaming.steam.enable) {
      setup.impermanence.keepDirs = [
        ".local/share/Steam"
        ".local/share/doublefine"
        ".local/share/FasterThanLight"
        ".local/share/Euro Truck Simulator 2"
        ".factorio"
      ];
    })
    (mkIf (cfgGaming.enable && cfgGaming.lutris) {
      setup.impermanence.keepDirs = [
        ".local/share/lutris"
        ".local/share/net.lutris.Lutris"
        ".cache/net.lutris.Lutris"
        ".cache/winetricks"
      ];
    })
    (mkIf (cfgGaming.enable && cfgGaming.minecraft) {
      setup.impermanence.keepDirs = [ ".local/share/PrismLauncher" ];
    })
    (mkIf (cfgGaming.enable && cfgGaming.emulators.ps3) {
      setup.impermanence.keepDirs = [
        ".config/rpcs3"
        ".cache/rpcs3"
      ];
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
  ];
}
