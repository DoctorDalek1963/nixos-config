{config, ...}: {
  imports = [./dyson.nix ./pi.nix ./rebecca.nix];

  users.mutableUsers = !config.setup.secrets.userPasswords.enable;
}
