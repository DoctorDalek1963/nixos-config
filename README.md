# NixOS Config

This is my configuration for all my NixOS machines. Installation should be fairly simple.

## Installation

1. Install NixOS on a new machine. The exact method shouldn't matter, but I've only tested 23.11 with GNOME.
2. Install `git` and enable flakes on the new machine.
3. Keep the `hardware-configuration.nix` file somewhere safe for now.
4. Clear `/etc/nixos` and clone this repo in its place. You probably want to change the permissions so that root access isn't needed.
5. Run `git remote rm origin && git remote add origin github-dd:DoctorDalek1963/nixos-config` to enable git pushing later.
6. Add your desired hostname to `flake.nix`, following the examples of the other hosts there.
7. Create a corresponding file in `machines/` for your new machine, following the examples of the other machine configs.
8. Move `hardware-configuration.nix` to `hardware/`.
9. Rebuild the system with `sudo nixos-rebuild switch --flake /etc/nixos#desiredHostname`.
    - Once you've done this the first time, you should be able to just do `sudo nixos-rebuild switch` in the future.
10. Copy your `age` private key into `/home/dyson/.config/sops/age/keys.txt`. The key is available on Dashlane if you can't copy it from another computer.
11. Run `nix run /etc/nixos/home-manager/dyson -- --flake /etc/nixos/home-manager/dyson switch` to setup home-manager.
12. Reboot the system, and everything should be setup!
