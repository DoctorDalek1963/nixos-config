{
  # We now use OS-level impermanence to generate the mount points.
  # See /modules/impermanence/users.nix
  imports = [./extras.nix];
}
