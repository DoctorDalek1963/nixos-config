1. Filter the .gitignore'd files (except the secret keys) out of the ISO
2. Extract /iso/config to /tmp/nixos-config to allow for secret provisioning after building the ISO (use systemd service to extract)
