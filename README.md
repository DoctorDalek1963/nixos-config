# NixOS Config

This is my configuration for all my NixOS machines. Installation should be fairly simple.

## Installation

1. Boot into any NixOS installation medium on the new machine and run `nixos-generate-config --show-hardware-config` to see the necessary hardware config. Put these options into `./machines/<hostname>/hardware.nix`.
2. Copy `machines/<hostname>/default.nix` from another host.
3. Create `machines/<hostname>/disko.nix` for filesystem config.
4. Add a section for the new machine in `flake.nix` and commit the changes.
5. Run `nix develop --command just build-iso-with-secrets`.
6. Copy the ISO file in `result/iso/` to a USB stick and boot it on the target machine.
7. Run `install-nixos-with-disko <hostname>` on the target machine. If it asks for a root password, just use something simple.
8. Reboot and cd into `/etc/nixos`. Run `nix develop --command just post-install`.
9. Reboot and everything will now be installed and setup!
10. Remember to delete the custom ISO from the USB, because it contains secret keys.

## Post-installation config

Some things are very difficult or impossible to configure declaratively.

You'll have login to your Google account with GNOME to access Google Calendar. You might be able to do this normally through the settings, but you might need to run `WEBKIT_FORCE_SANDBOX=0 gnome-control-center online-accounts` to open the settings.

You'll have to login to Firefox to enable Firefox Sync. The device name should already be set up.

Firefox add-ons need to be manually enabled and configured. I won't enumerate all of my add-on settings here, but I'd recommend copying them from another machine.

You'll also have to add any rclone remotes manually. Then add the names of the remotes and their mountpoints to `home-manager/dyson/flake.nix`.

Copy your sops age keys to `~/.config/sops/age/keys.txt`. The keys should be on separate lines.
