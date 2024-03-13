{
  description = "DoctorDalek1963's NixOS flake";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-23.11";
  };

  outputs = {nixpkgs, ...}: {
    nixosConfigurations = {
      "VirtualBox-NixOS" = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        modules = [./machines/vbox.nix];
      };
    };
  };
}
