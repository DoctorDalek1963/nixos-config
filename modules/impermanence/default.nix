{
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.setup.impermanence;
in {
  imports = [inputs.impermanence.nixosModules.impermanence];

  # Taken from https://github.com/nix-community/impermanence and
  # https://gitlab.com/hmajid2301/dotfiles/-/blob/631af0889586323dd106b26b5bd8b7f22852aa37/modules/nixos/system/impermanence/default.nix
  config = lib.mkIf cfg.enable {
    # For debugging
    # boot = {
    #   kernelParams = ["rd.systemd.debug_shell"];
    #   initrd.systemd.emergencyAccess = true;
    # };

    environment.persistence."/persist" = {
      enable = true;
      hideMounts = true;

      directories =
        [
          "/etc/nixos"
          "/var/log"
          "/var/lib/bluetooth"
          "/var/lib/nixos"
          "/var/lib/systemd/coredump"
        ]
        ++ cfg.keepDirs;

      # {
      #   directory = "/var/lib/colord";
      #   user = "colord";
      #   group = "colord";
      #   mode = "u=rwx,g=rx,o=";
      # }

      files = ["/etc/machine-id"] ++ cfg.keepFiles;
    };

    # "We trust you have received the usual lecture..."
    security.sudo.extraConfig = "Defaults lecture = never";

    # programs.fuse.userAllowOther = true;

    # This script does the actual wipe of the system
    # So if it doesn't run, the btrfs system effectively acts like a normal system
    # Originally taken from https://github.com/NotAShelf/nyx/blob/2a8273ed3f11a4b4ca027a68405d9eb35eba567b/modules/core/common/system/impermanence/default.nix
    boot.initrd.systemd = {
      enable = true;

      services.rollback-btrfs-rootfs = {
        description = "Rollback BTRFS rootfs subvolume to blank";

        wantedBy = ["initrd.target"];

        # We want to do this after we've setup LUKS, but before the system mounts /
        after = ["systemd-cryptsetup@cryptroot.service"];
        before = ["sysroot.mount"];

        unitConfig.DefaultDependencies = "no";
        serviceConfig.Type = "oneshot";

        script = ''
          mkdir -p /mnt

          # We first mount the btrfs rootfs to /mnt so we can manipulate btrfs subvolumes
          mount -o subvol=/ /dev/mapper/cryptroot /mnt
          btrfs subvolume list -o /mnt/rootfs

          # While we're tempted to just delete /root and create a new snapshot
          # from /rootfs-blank, /rootfs is already populated at this point with a
          # number of subvolumes, which makes `btrfs subvolume delete` fail, so
          # we remove them first

          btrfs subvolume list -o /mnt/rootfs |
          cut -f9 -d' ' |
          while read subvolume; do
            echo "deleting /$subvolume subvolume..."
            btrfs subvolume delete "/mnt/$subvolume"
          done &&
          echo "deleting /rootfs subvolume..." &&
          btrfs subvolume delete /mnt/rootfs

          echo "restoring blank /rootfs subvolume..."
          btrfs subvolume snapshot /mnt/rootfs-blank /mnt/rootfs

          # Once we're done rolling back to a blank snapshot,
          # we can unmount /mnt and continue on the boot process
          umount /mnt
        '';
      };
    };
  };
}
