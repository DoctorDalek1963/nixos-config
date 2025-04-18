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

    # Allow other users to access things through bind mounts. Used by
    # home-manager impermanence for sudo operations and the like.
    # NOTE: This option has broken boots before in VirtualBox-NixOS
    programs.fuse.userAllowOther = true;

    boot = {
      postBootCommands = let
        commands =
          builtins.attrValues
          (builtins.mapAttrs (
              name: conf: ''
                mkdir -p /persist${conf.home.homeDirectory}
                chown ${name}:users /persist${conf.home.homeDirectory}
              ''
            )
            config.home-manager.users);
      in
        lib.strings.concatStringsSep "\n" commands;

      kernelParams = lib.optional cfg.debug "rd.systemd.debug_shell";

      initrd.systemd = {
        enable = true;
        emergencyAccess = cfg.debug;

        # This script does the actual wipe of the system
        # So if it doesn't run, the btrfs system effectively acts like a normal system
        # Originally taken from https://github.com/NotAShelf/nyx/blob/2a8273ed3f11a4b4ca027a68405d9eb35eba567b/modules/core/common/system/impermanence/default.nix
        services.wipe-btrfs-rootfs = {
          description = "Wipe BTRFS rootfs subvolume";

          wantedBy = ["initrd.target"];

          # We want to do this after we've setup LUKS, but before the system mounts /
          after = lib.mkIf cfg.isEncrypted ["systemd-cryptsetup@cryptroot.service"];
          before = ["sysroot.mount"];

          unitConfig.DefaultDependencies = "no";
          serviceConfig.Type = "oneshot";

          script = ''
            mkdir -p /mnt

            # We first mount the btrfs rootfs to /mnt so we can manipulate btrfs subvolumes
            mount -o subvol=/ ${cfg.mainDriveDevice} /mnt

            # Move the current /rootfs subvolume to an old_roots folder so that
            # it can be restored later if needed
            if [[ -e /mnt/rootfs ]]; then
                mkdir -p /mnt/old_roots
                timestamp=$(date --date="@$(stat -c %Y /mnt/rootfs)" "+%Y-%m-%-d_%H:%M:%S")
                mv /mnt/rootfs "/mnt/old_roots/$timestamp"

                # Carrying around old swapfiles really clogs up the drive
                rm -f "/mnt/old_roots/$timestamp/swapfile"
            fi

            # While we're tempted to just delete /rootfs and create a new
            # subvolume, /rootfs is already populated at this point with a number
            # of subvolumes, which makes `btrfs subvolume delete` fail, so we
            # remove them first
            delete_subvolume_recursively() {
                IFS=$'\n'
                for i in $(btrfs subvolume list -o "$1" | cut -f 9- -d ' '); do
                    delete_subvolume_recursively "/mnt/$i"
                done
                btrfs subvolume delete "$1"
            }

            # Now delete all /rootfs subvolumes from more than 14 days ago
            for i in $(find /mnt/old_roots/ -maxdepth 1 -mtime +14); do
                delete_subvolume_recursively "$i"
            done

            # Then create a new, empty /rootfs and continue the boot process
            btrfs subvolume create /mnt/rootfs
            umount /mnt
          '';
        };
      };
    };
  };
}
