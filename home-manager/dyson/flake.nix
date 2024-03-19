{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # unstable.url = "github:nixos/nixpkgs/nixos-unstable";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    firefox-addons = {
      url = "gitlab:rycee/nur-expressions?dir=pkgs/firefox-addons";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-flake.url = "github:DoctorDalek1963/nixvim-config";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "dyson";
    pkgs = import nixpkgs {
      inherit system;
    };
    extraSpecialArgs = {
      inherit system;
      my-nixvim = inputs.nixvim-flake.packages.${system}.default;
    };
  in {
    packages.${system}.default = home-manager.defaultPackage.${system};

    homeConfigurations = {
      "${username}@Sasha-Ubuntu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "Sasha-Ubuntu";
            };
          }
          ./modules/secrets/provisioning.nix
          ./modules/gaming.nix
          ./modules/maths.nix
          ./modules/programming.nix
        ];
      };
      "${username}@Harold-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "Harold-NixOS";
            };
          }
          ./modules/secrets/provisioning.nix.nix
          ./modules/secrets/gnome-keyring.nix
          ./modules/gnome/default.nix
          ./modules/firefox.nix
          ./modules/maths.nix
          ./modules/programming.nix
        ];
      };
      "${username}@VirtualBox-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "VirtualBox-NixOS";
            };
          }
          ./modules/secrets/provisioning.nix
          ./modules/secrets/gnome-keyring.nix
          ./modules/gnome/default.nix
          ./modules/firefox.nix
          ./modules/programming.nix
        ];
      };
    };
  };
}
