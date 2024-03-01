{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nixvim = {
      #url = "github:nix-community/nixvim/nixos-23.11";
      url = "github:DoctorDalek1963/nixvim";
      #inputs.nixpkgs.follows = "unstable";
    };
  };

  outputs = {
    #self,
    nixpkgs,
    #unstable,
    home-manager,
    nixvim,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    overlays = [inputs.neovim-nightly-overlay.overlay];
  in {
    defaultPackage.${system} = home-manager.defaultPackage.${system};

    homeConfigurations = {
      dyson = home-manager.lib.homeManagerConfiguration {
        pkgs = import nixpkgs {
          inherit system;
          inherit overlays; # Comment this out to use stable neovim again
          config = {allow-unfree = true;};
        };
        extraSpecialArgs = {
          #inherit unstable;
          inherit nixvim;
        };
        modules = [
          ./home.nix
          nixvim.homeManagerModules.nixvim
        ];
      };
    };
  };
}
