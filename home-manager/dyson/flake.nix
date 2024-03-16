{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-flake.url = "github:DoctorDalek1963/nixvim-config";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    #self,
    nixpkgs,
    #unstable,
    home-manager,
    nixvim-flake,
    sops-nix,
    ...
  }: let
    system = "x86_64-linux";
    username = "dyson";
    pkgs = import nixpkgs {
      inherit system;
    };
    extraSpecialArgs = {
      #inherit unstable;
      inherit sops-nix system username;
      homedir = "/home/${username}";
      my-nixvim = nixvim-flake.packages.${system}.default;
    };
  in {
    packages.${system}.default = home-manager.defaultPackage.${system};

    homeConfigurations = {
      "${username}@Sasha-Ubuntu" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = extraSpecialArgs // {hostname = "Sasha-Ubuntu";};
        modules = [
          ./modules/core.nix
          ./modules/shells/bash.nix
          ./modules/secrets/provisioning.nix
          ./modules/gaming.nix
          ./modules/maths.nix
          ./modules/programming.nix
        ];
      };
      "${username}@Harold-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = extraSpecialArgs // {hostname = "Harold-NixOS";};
        modules = [
          ./modules/core.nix
          ./modules/shells/bash.nix
          ./modules/secrets/provisioning.nix.nix
          ./modules/secrets/gnome-keyring.nix
          ./modules/gnome/default.nix
          ./modules/firefox.nix
          ./modules/maths.nix
          ./modules/programming.nix
        ];
      };
      "${username}@VirtualBox-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs;
        extraSpecialArgs = extraSpecialArgs // {hostname = "VirtualBox-NixOS";};
        modules = [
          ./modules/core.nix
          ./modules/shells/bash.nix
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
