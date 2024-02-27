{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
  };

  outputs = { self, nixpkgs, unstable, home-manager, ... }@inputs:
  let
    system = "x86_64-linux";
    overlays = [ inputs.neovim-nightly-overlay.overlay ];
  in
  {
    defaultPackage.${system} = home-manager.defaultPackage.${system};

    homeConfigurations = {
      dyson = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          inherit overlays;
          config = { allow-unfree = true; };
        };
        extraSpecialArgs = { inherit unstable; };
        modules = [
          ./home.nix
        ];
      };
    };
  };
}
