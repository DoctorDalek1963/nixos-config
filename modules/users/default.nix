{ config, ... }:
{
  imports = [
    ./dyson.nix
    ./pi.nix
    ./rebecca.nix
    ./deterministicIds.nix
  ];

  users.mutableUsers = !config.setup.secrets.userPasswords.enable;
}
