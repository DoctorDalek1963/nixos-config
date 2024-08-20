{
  lib,
  config,
  osConfig,
  ...
}: let
  inherit (lib) mkIf mkMerge;

  osSetup = osConfig.setup;
  cfgGaming = osSetup.gaming;
in {
  config = mkMerge [
    (mkIf true {
      setup.impermanence.keepDirs = ["repos"];
    })
    (mkIf cfgGaming.enable {
      setup.impermanence.keepDirs = ["Games"];
    })
    (mkIf (cfgGaming.enable && cfgGaming.steam.enable) {
      setup.impermanence.keepDirs = [
        ".local/share/Steam"
        ".factorio"
      ];
    })
    (mkIf (cfgGaming.enable && cfgGaming.minecraft) {
      setup.impermanence.keepDirs = [".local/share/PrismLauncher"];
    })
    (mkIf (cfgGaming.enable && cfgGaming.emulators.ps3) {
      setup.impermanence.keepDirs = [
        ".config/rpcs3"
        ".cache/rpcs3"
      ];
    })
    (mkIf osSetup.virtualBox.host.enable {
      setup.impermanence.keepDirs = ["VirtualBox VMs"];
    })
  ];
}
