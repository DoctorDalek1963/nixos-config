# NixOS Config

This is my configuration for all my NixOS machines. Installation should be fairly simple.

## Installation

1. Install NixOS on a new machine. The exact method shouldn't matter, but I've only tested 23.11 with GNOME.
2. Install `git` on the new machine.
3. Keep the `hardware-configuration.nix` file somewhere safe for now.
4. Clear `/etc/nixos` and clone this repo in its place. You probably want to change the permissions so that root access isn't needed.
5. Add your desired hostname to `flake.nix`, following the examples of the other hosts there.
6. Create a corresponding file in `machines/` for your new machine, following the examples of the other machine configs.
7. Move `hardware-configuration.nix` to `hardware/`.
8. Rebuild the system with `sudo nixos-rebuild switch --flake /etc/nixos#desiredHostname`.
9. Run `nix run /etc/nixos/home-manager/dyson -- --flake /etc/nixos/home-manager/dyson switch` to setup home-manager.
10. Reboot the system, and everything should be setup!
