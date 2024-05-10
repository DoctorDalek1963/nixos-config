{config, ...}: {
  imports = [./dyson.nix ./pi.nix];

  users.mutableUsers = !config.setup.secrets.userPasswords.enable;
}
