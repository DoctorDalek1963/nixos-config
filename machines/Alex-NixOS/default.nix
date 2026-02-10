{ inputs, ... }:
{
  imports = [
    inputs.disko.nixosModules.disko
    ./disko.nix
    ./hardware.nix
    ./snapper.nix
    ./btrfs.nix
  ];
}
