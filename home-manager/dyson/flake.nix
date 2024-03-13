{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-flake.url = "github:DoctorDalek1963/nixvim-config";
  };

  outputs = {
    #self,
    nixpkgs,
    #unstable,
    home-manager,
    nixvim-flake,
    ...
  }: let
    system = "x86_64-linux";
    pkgs = import nixpkgs {
      inherit system;
    };
    extraSpecialArgs = {
      #inherit unstable;
      inherit nixvim-flake system;
    };
  in {
    packages.${system}.default = home-manager.defaultPackage.${system};

    homeConfigurations = {
      "dyson@Sasha-Ubuntu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./modules/core.nix
          ./modules/gaming.nix
          ./modules/maths.nix
          ./modules/programming.nix
        ];
      };
      "dyson@Harold-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./modules/core.nix
          ./modules/maths.nix
          ./modules/programming.nix
        ];
      };
      "dyson@VirtualBox-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./modules/core.nix
          ./modules/gnome/default.nix
          ./modules/programming.nix
        ];
      };
    };
  };
}
