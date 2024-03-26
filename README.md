# NixOS Config

This is my configuration for all my NixOS machines. Installation should be fairly simple.

## Installation

1. Install NixOS on a new machine. The exact method shouldn't matter, but I've only tested 23.11 with GNOME.
2. Install `git` and enable flakes on the new machine.
3. Keep the `hardware-configuration.nix` file somewhere safe for now.
4. Clear `/etc/nixos` and clone this repo in its place. You probably want to change the permissions so that root access isn't needed.
5. Run `git remote rm origin && git remote add origin github-dd:DoctorDalek1963/nixos-config.git` to enable git pushing later.
6. Add your desired hostname to `flake.nix`, following the examples of the other hosts there.
7. Create a corresponding file in `machines/` for your new machine, following the examples of the other machine configs.
8. Move `hardware-configuration.nix` to `hardware/`.
9. Rebuild the system with `sudo nixos-rebuild switch --flake /etc/nixos#desiredHostname`.
    - Once you've done this the first time, you should be able to just do `sudo nixos-rebuild switch` in the future.
10. Copy your `age` private key into `/home/dyson/.config/sops/age/keys.txt`. The key is available on Dashlane if you can't copy it from another computer.
11. Run `nix run /etc/nixos/home-manager/dyson -- --flake /etc/nixos/home-manager/dyson switch` to setup home-manager.
12. Reboot the system, and everything should be setup!

## Post-installation config

Some things are very difficult or impossible to configure declaratively.

You'll have login to your Google account with GNOME to access Google Calendar. You might be able to do this normally through the settings, but you might need to run `WEBKIT_FORCE_SANDBOX=0 gnome-control-center online-accounts` to open the settings.

The first time you use an SSH key, GNOME Keyring will prompt you for the passphrase. These will be available in `/run/user/<uid>/secrets/ssh/<key_name>/passphrase`.

You'll have to login to Firefox to enable Firefox Sync. The device name should already be set up.

Firefox add-ons need to be manually configured. Refined GitHub needs a token, which is available in `/run/user/1000/secrets/firefox/extensions/refined_github/personal_access_token`. I won't enumerate all of my add-on settings here, but I'd recommend copying them from another machine.

You'll also have to add any rclone remotes manually. Then add the names of the remotes and their mountpoints to `home-manager/dyson/flake.nix`.
