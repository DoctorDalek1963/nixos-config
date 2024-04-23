{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko ./disko.nix ./hardware.nix];
}
