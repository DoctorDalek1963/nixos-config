{
  pkgs,
  lib,
  config,
  ...
}:
let
  cfg = config.setup.virtManager.host;
in
{
  config = lib.mkIf cfg.enable {
    programs.virt-manager.enable = true;

    virtualisation.libvirtd = {
      enable = true;
      qemu.vhostUserPackages = with pkgs; [ virtiofsd ];
    };

    users.groups.libvirtd.members = cfg.users;

    setup.impermanence.keepDirs = [ "/var/lib/libvirt" ];
  };
}
