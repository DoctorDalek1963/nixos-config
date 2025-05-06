{
  description = "DoctorDalek1963's NixOS flake";

  inputs = {
    # Core
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable"; # TODO (25.05): Actually use nixos-25.05 when it's available
    nixpkgs-unstable.url = "github:NixOS/nixpkgs/nixos-unstable";
    nur = {
      url = "github:nix-community/nur";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    lix-module = {
      url = "https://git.lix.systems/lix-project/nixos-module/archive/2.92.0-3.tar.gz";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Repo management
    flake-parts.url = "github:hercules-ci/flake-parts";
    pre-commit-hooks = {
      url = "github:cachix/pre-commit-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Hardware and device management
    disko = {
      url = "github:nix-community/disko";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    impermanence.url = "github:nix-community/impermanence";
    nixos-hardware.url = "github:NixOS/nixos-hardware";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Personal projects for home server
    tic-tac-toe = {
      url = "github:DoctorDalek1963/tic-tac-toe";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    winter-wonderlights = {
      url = "github:DoctorDalek1963/winter-wonderlights";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    wordle = {
      url = "github:DoctorDalek1963/wordle";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Other home server stuff
    whisper-asr-webservice-flake.url = "github:DoctorDalek1963/whisper-asr-webservice-flake";

    # home-manager stuff
    home-manager = {
      url = "github:nix-community/home-manager/master"; # TODO (25.05): Go back to release-25.05 once it's available
      inputs.nixpkgs.follows = "nixpkgs";
    };

    lintrans.url = "github:DoctorDalek1963/lintrans";

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-config = {
      url = "github:DoctorDalek1963/nixvim-config";
      inputs = {
        # nixpkgs.follows = "nixpkgs"; # Only while nixvim-config uses stable nixpkgs
        flake-parts.follows = "flake-parts";
      };
    };
    xremap = {
      url = "github:xremap/nix-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = {
    self,
    nixpkgs,
    flake-parts,
    ...
  } @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      flake.nixosConfigurations = import ./defs.nix {
        inherit
          self
          nixpkgs
          inputs
          ;
      };

      imports = [
        inputs.pre-commit-hooks.flakeModule
      ];

      systems = ["x86_64-linux" "aarch64-linux"];
      perSystem = {
        config,
        system,
        ...
      }: let
        pkgs = nixpkgs.legacyPackages.${system};
      in {
        devShells.default = pkgs.mkShell {
          nativeBuildInputs = with pkgs; [
            # Secrets
            age
            sops

            # Build ISO with justfile
            just
            fd
            nix-output-monitor
            jq
            cachix
          ];
          shellHook = ''
            ${config.pre-commit.installationScript}
          '';
        };

        # See https://flake.parts/options/pre-commit-hooks-nix and
        # https://github.com/cachix/git-hooks.nix/blob/master/modules/hooks.nix
        # for all the available hooks and options
        pre-commit = {
          # This repo contains some large images and patch files with
          # necessary whitespace "errors", so we don't want to run the
          # pre-commit hooks on every file when checking the flake
          check.enable = false;

          settings.hooks = {
            check-added-large-files.enable = true;
            check-merge-conflicts.enable = true;
            check-toml.enable = true;
            check-vcs-permalinks.enable = true;
            check-yaml.enable = true;
            end-of-file-fixer.enable = true;

            trim-trailing-whitespace = {
              enable = true;
              excludes = [''.+\.patch$''];
            };

            alejandra.enable = true;
            deadnix.enable = true;
            statix.enable = true;
          };
        };
      };
    };
}
