{ inputs, ... }:
{
  imports = [
    inputs.sops-nix.homeManagerModules.sops
    ./provisioning.nix
    ./keychain.nix
  ];
}
