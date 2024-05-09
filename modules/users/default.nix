{config, ...}: {
  imports = [./dyson.nix];

  users.mutableUsers = !config.setup.secrets.userPasswords.enable;
}
