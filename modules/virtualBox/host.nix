{
  pkgs,
  lib,
  config,
  ...
}: let
  inherit (lib) mkIf mkMerge;
  cfg = config.setup.virtualBox.host;
in {
  config = mkIf cfg.enable (mkMerge [
    (mkIf cfg.asSpecialisation {
      specialisation.virtualbox.configuration = {
        virtualisation.virtualbox.host.enable = true;
        users.groups.vboxusers.members = cfg.users;

        # VirtualBox needs particular kernel modules that don't always compile
        # on newer kernels, but should work on the latest LTS kernel
        boot.kernelPackages = lib.mkForce pkgs.linuxPackages;
      };
    })
    (mkIf (!cfg.asSpecialisation) {
      virtualisation.virtualbox.host.enable = true;
      users.groups.vboxusers.members = cfg.users;
    })
  ]);
}
