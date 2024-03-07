# NixOS Config

This is my configuration for all my NixOS machines. Installation should be fairly simple.

## Installation

1. Install NixOS on a new machine. The exact method shouldn't matter, but I've only tested 23.11 with GNOME.
2. Install `git` on the new machine.
3. Keep the `hardware-configuration.nix` file somewhere safe for now.
4. Clear `/etc/nixos` and clone this repo in its place. You probably want to change the permissions so that root access isn't needed.
5. Run `cat /sys/class/dmi/id/product_uuid` to get the UUID for the new machine. Add this UUID to `configuration.nix` and point it at a new file in `machines/`.
6. The file in `machines/` should follow the template of the others. It should set the hostname, include the corresponding hardware config in the `hardware/` directory, and include all the desired modules.
7. Rebuild the system with `sudo nixos-rebuild switch`.
8. Run `nix run /etc/nixos/home-manager/dyson -- --flake /etc/nixos/home-manager/dyson switch` to setup home-manager.
9. Reboot the system, and everything should be setup!
