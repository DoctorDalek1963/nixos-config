{ inputs, ... }:
{
  flake-file.inputs = {
    impermanence.url = "github:nix-community/impermanence";
  };

  flake.aspects = {
    global-options = {
      homeManager =
        { lib, ... }:
        {
          options.impermanence = with lib; {
            directories = mkOption {
              type = types.listOf (types.either types.nonEmptyStr types.attrs);
              default = [ ];
            };

            files = mkOption {
              type = types.listOf (types.either types.nonEmptyStr types.attrs);
              default = [ ];
            };
          };
        };

      nixos =
        { lib, ... }:
        {
          options.impermanence = with lib; {
            enable = mkEnableOption "impermanence";

            drive = {
              device = mkOption {
                type = types.nonEmptyStr;
                description = "The device that contains `/persist`.";
              };

              isEncrypted = mkOption {
                type = types.bool;
                description = ''
                  Is the filesystem encrypted?

                  If so, we expect / to be encrypted with LUKS and called cryptroot.
                '';
              };
            };

            debug = mkOption {
              type = types.bool;
              default = false;
              description = "Enable debugging of impermanence infrastructure.";
            };

            directories = mkOption {
              type = types.listOf (types.either types.nonEmptyStr types.attrs);
              default = [ ];
            };

            files = mkOption {
              type = types.listOf (types.either types.nonEmptyStr types.attrs);
              default = [ ];
            };
          };
        };
    };

    impermanence = {
      nixos =
        { lib, config, ... }:
        {
          imports = [
            inputs.impermanence.nixosModules.impermanence
          ];

          config =
            let
              cfg = config.impermanence;

              wipeScript =
                # bash
                ''
                  mkdir -p /mnt

                  # We first mount the btrfs rootfs to /mnt so we can manipulate btrfs subvolumes
                  mount -o subvol=/ -t btrfs ${cfg.drive.device} /mnt

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
            in
            {
              impermanence.enable = true;

              environment.persistence."/persist" = {
                enable = true;
                hideMounts = true;

                directories = [
                  "/etc/nixos"
                  "/var/log"
                  "/var/lib/nixos"
                  "/var/lib/systemd/coredump"
                ]
                ++ cfg.directories;

                # {
                #   directory = "/var/lib/colord";
                #   user = "colord";
                #   group = "colord";
                #   mode = "u=rwx,g=rx,o=";
                # }

                files = [ "/etc/machine-id" ] ++ cfg.files;

                users = builtins.listToAttrs (
                  map (name: {
                    inherit name;
                    value = {
                      inherit (config.home-manager.users."${name}".setup.impermanence) directories files;
                    };
                  }) (builtins.attrNames config.home-manager.users)
                );
              };

              # "We trust you have received the usual lecture..."
              security.sudo.extraConfig = "Defaults lecture = never";

              # Allow other users to access things through bind mounts. Used by
              # home-manager impermanence for sudo operations and the like.
              # NOTE: This option has broken boots before in VirtualBox-NixOS
              programs.fuse.userAllowOther = true;

              boot = {
                postBootCommands =
                  let
                    commands = builtins.attrValues (
                      builtins.mapAttrs (name: conf: ''
                        mkdir -p /persist${conf.home.homeDirectory}
                        chown ${name}:users /persist${conf.home.homeDirectory}
                      '') config.home-manager.users
                    );
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

                    wantedBy = [ "initrd.target" ];

                    # We want to do this after we've setup LUKS, but before the system mounts /
                    after = lib.mkIf cfg.drive.isEncrypted [ "systemd-cryptsetup@cryptroot.service" ];
                    before = [ "sysroot.mount" ];

                    unitConfig.DefaultDependencies = "no";
                    serviceConfig.Type = "oneshot";

                    script = wipeScript;
                  };
                };
              };
            };
        };
    };
  };
}
