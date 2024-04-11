{
  description = "DoctorDalek1963's home-manager flake";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-23.11";
    unstable.url = "github:nixos/nixpkgs/nixos-unstable";
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
    unstable,
    home-manager,
    ...
  } @ inputs: let
    system = "x86_64-linux";
    username = "dyson";

    # Access unstable packages through pkgs.unstable
    unstable-overlay = final: _prev: {
      unstable = import inputs.unstable {
        inherit (final) system;
      };
    };

    pkgs = import nixpkgs {
      inherit system;
      overlays = [unstable-overlay inputs.nur.overlay];
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
              isNixOS = true;

              desktopEnvironments.gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
                background = ./files/desktop-backgrounds/kurzgesagt-space.webp;
              };

              terminalTools = {
                theme = "catppuccin-macchiato";
                useThemeInTerminalItself = true;
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
              isNixOS = false;
              hasDvdDrive = true;
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
              isNixOS = true;
              isLaptop = true;
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
              isNixOS = true;

              desktopEnvironments.gnome = {
                enable = true;
                theme = "vimix-amethyst";
                background = ./files/desktop-backgrounds/virtualbox.jpg;
              };
              # firefox.enable = true;
              # rclone = {
              #   enable = true;
              #   automounts = [
              #     {
              #       remote = "OneDrive";
              #       mountpoint = "/home/${username}/OneDrive";
              #       readonly = true;
              #     }
              #   ];
              # };
              terminalTools.nvimCustom = false;
              miscPrograms.xremap = true;
            };
          }
        ];
      };
    };
  };
}
