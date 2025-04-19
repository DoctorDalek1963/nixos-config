{inputs, ...}: {
  imports = [inputs.disko.nixosModules.disko ./disko.nix ./externalDrives.nix ./hardware.nix ./snapper.nix];
}
