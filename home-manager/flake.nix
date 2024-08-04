{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-24.05";
    # unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-flake.url = "github:DoctorDalek1963/nixvim-config";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs = {
        nixpkgs.follows = "nixpkgs";
        nixpkgs-stable.follows = "nixpkgs";
      };
    };
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    nixpkgs,
    home-manager,
    ...
  } @ inputs: let
    username = "dyson";

    # Access unstable packages through pkgs.unstable
    # unstable-overlay = _final: _prev: {
    #   unstable = inputs.unstable.legacyPackages.${system};
    # };

    mkPkgs = system:
      import nixpkgs {
        inherit system;
        overlays = [
          # unstable-overlay
          inputs.nur.overlay
        ];
      };

    extraSpecialArgs = {inherit inputs;};
  in {
    packages = {
      "x86_64-linux".default = home-manager.defaultPackage."x86_64-linux";
      "aarch64-linux".default = home-manager.defaultPackage."aarch64-linux";
    };

    homeConfigurations = import ./defs.nix {
      inherit
        home-manager
        username
        mkPkgs
        extraSpecialArgs
        ;
    };
  };
}
