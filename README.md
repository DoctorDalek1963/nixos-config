# NixOS Config

> [!WARNING]
> This is my personal NixOS configuration. It is not meant as a template and should not be used like one. Feel free to take ideas from my config, but be aware that this is not aimed at NixOS beginners.

## Installation

1. Boot into any NixOS installation medium on the new machine and run `nixos-generate-config --show-hardware-config` to see the necessary hardware config. Put these options into `./machines/<hostname>/hardware.nix`.
2. Copy `machines/<hostname>/default.nix` from another host.
3. Create `machines/<hostname>/disko.nix` for filesystem config.
4. Add a section for the new machine in `defs.nix` and commit the changes.
5. Run `nix develop --command just build-iso-with-secrets`.
6. Copy the ISO file in `result/iso/` to a USB stick and boot it on the target machine.
7. Run `install-nixos-with-disko <hostname>` on the target machine. If it asks for a root password, just use something simple. You may need to run `connect-wifi` or run `set-password` to write a LUKS password to `/tmp/password` or something.
8. Reboot and cd into `/etc/nixos`. Run `nix develop --command just post-install`.
9. Remember to delete the custom ISO from the USB, because it contains secret keys.

## Post-installation config

Some things are very difficult or impossible to configure declaratively.

You'll have to login to Firefox to enable Firefox Sync. The device name should already be set up.

You'll also have to add any rclone remotes manually. Then add the names of the remotes and their mountpoints to `home-manager/defs.nix`.

### Android TV

For an Android TV installation, make sure the Tailscale key is set correctly before install so that you can SSH into the device immediately. Then run `just atv-init`, reboot, then run `just atv-register` and follow the instructions.
