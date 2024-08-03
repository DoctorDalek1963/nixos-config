# ISO

- Extract /iso/config to /tmp/nixos-config to allow for secret provisioning after building the ISO (use systemd service to extract)
- Add script to enter LUKS password without printing it on screen
- 1. Add flags to install-nixos-with-disko to run `nixos-enter --command "cd /etc/nixos && nix develop --command just post-install username"`
  2. Allow for multiple users
- Add colors to install scripts in ISO

# Everything else

- Fix OpenRGB server
- Fix MAM IP address seeding problems (mam-dynamic-ip updates the IP address through
    the VPN, which is fine for Transmission, but then Prowlarr uses the same session
    ID without a VPN. Should I have two sessions and keep them both updated?)
