# NixOS Config

This is my configuration for all my NixOS machines. Installation should be fairly simple.

## Installation

1. Install NixOS on a new machine. The exact method shouldn't matter, but I've only tested 23.11 with GNOME.
2. Install `git` and enable flakes on the new machine.
3. Keep the `configuration.nix` and `hardware-configuration.nix` files somewhere safe for now.
4. Clear `/etc/nixos` and clone this repo in its place. You probably want to change the permissions so that root access isn't needed.
5. Run `git remote rm origin && git remote add origin github-dd:DoctorDalek1963/nixos-config.git` to enable git pushing later.
6. Add your desired hostname and config to `flake.nix`, following the examples of the other hosts there. You might want to do this on a different machine before installation.
8. Move `hardware-configuration.nix` to `hardware/` and make any necessary adjustments. Remember to copy the bootloader config from `configuration.nix`.
9. Copy your `age` private keys to their proper places in `/etc/nixos/sops-secrets/key.txt` and `/etc/nixos/home-manager/dyson/sops-secrets/key.txt`. The keys are available on Dashlane if you can't copy them from another computer.
10. Rebuild the system with `sudo nixos-rebuild switch --flake /etc/nixos#desiredHostname`.
    - Once you've done this the first time, you should be able to just do `sudo nixos-rebuild switch` in the future.
11. Run `nix run /etc/nixos/home-manager/dyson -- --flake /etc/nixos/home-manager/dyson switch` to setup home-manager.
    - Once you've done this the first time, you should be able to just do `home-manager switch` in the future.
12. Reboot the system, and everything should be setup!

## Post-installation config

Some things are very difficult or impossible to configure declaratively.

You'll have login to your Google account with GNOME to access Google Calendar. You might be able to do this normally through the settings, but you might need to run `WEBKIT_FORCE_SANDBOX=0 gnome-control-center online-accounts` to open the settings.

The first time you open a terminal, you will be prompted for SSH key passphrases. These will be available in `/run/user/<uid>/secrets/ssh/<key_name>/passphrase`.

You'll have to login to Firefox to enable Firefox Sync. The device name should already be set up.

Firefox add-ons need to be manually configured. Refined GitHub needs a token, which is available in `/run/user/<uid>/secrets/firefox/extensions/refined_github/personal_access_token`. I won't enumerate all of my add-on settings here, but I'd recommend copying them from another machine.

You'll also have to add any rclone remotes manually. Then add the names of the remotes and their mountpoints to `home-manager/dyson/flake.nix`.

Copy your sops age keys to `~/.config/sops/age/keys.txt`. The keys should be on separate lines.

To setup the OpenVPN configs in GNOME's VPN menu, you'll need to import the `/etc/openvpn/<name-of-vpn>.ovpn` and copy the username and password from the `/run/secrets/openvpn/<name-of-vpn>/user-pass` file. The username is on the first line and the password is on the second line.
