{ inputs, ... }:
{
  system.stateVersion = "23.11";

  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./externalDrives.nix
    ./hardware.nix
    ./snapper.nix
    ./btrfs.nix
  ];
}
