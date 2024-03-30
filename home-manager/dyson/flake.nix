{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    # unstable.url = "github:nixos/nixpkgs/nixos-unstable";
    nur.url = "github:nix-community/nur";

    home-manager = {
      url = "github:nix-community/home-manager/release-23.11";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nix-index-database = {
      url = "github:nix-community/nix-index-database";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixvim-flake.url = "github:DoctorDalek1963/nixvim-config";
    sops-nix = {
      url = "github:Mic92/sops-nix";
      inputs.nixpkgs.follows = "nixpkgs";
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
    system = "x86_64-linux";
    username = "dyson";
    pkgs = import nixpkgs {
      inherit system;
      overlays = [inputs.nur.overlay];
    };
    extraSpecialArgs = {
      inherit system inputs;
    };
  in {
    packages.${system}.default = home-manager.defaultPackage.${system};

    homeConfigurations = {
      "${username}@Alex-NixOS" = home-manager.lib.homeManagerConfiguration {
        inherit pkgs extraSpecialArgs;
        modules = [
          ./setup.nix
          {
            setup = {
              inherit username;
              hostname = "Alex-NixOS";

              desktopEnvironments.gnome = {
                enable = true;
                theme = "vimix-amethyst";
                background = ./files/desktop-backgrounds/kurzgesagt-space.webp;
              };

              firefox.enable = true;

              rclone = {
                enable = true;
                automounts = [
                  {
                    remote = "OneDrive";
                    mountpoint = "/home/${username}/OneDrive";
                  }
                ];
              };

              maths.enable = true;

              programming = {
                rust = true;
              };

              miscPrograms = {
                discord = true;
                obsidian = true;
                vlc = true;
                xremap = true;
              };
            };
          }
        ];
      };

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
              desktopEnvironments.gnome = {
                enable = true;
                theme = "vimix-amethyst";
                background = ./files/desktop-backgrounds/kurzgesagt-space.webp;
              };
              firefox.enable = true;
              rclone = {
                enable = true;
                automounts = [
                  {
                    remote = "OneDrive";
                    mountpoint = "/home/${username}/OneDrive";
                    readonly = true;
                  }
                ];
              };
              miscPrograms.xremap = true;
            };
          }
        ];
      };
    };
  };
}
