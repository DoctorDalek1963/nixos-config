{ inputs, ... }:
{
  flake-file.inputs = {
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  imports = [
    inputs.disko.flakeModules.disko
  ];

  flake.aspects.disko = {
    nixos = {
      imports = [
        inputs.disko.nixosModules.disko
      ];
    };
  };
}
