{
  home-manager,
  username,
  mkPkgs,
  extraSpecialArgs,
}: {
  "${username}@Alex-NixOS" = let
    system = "x86_64-linux";
  in
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = extraSpecialArgs // {inherit system;};
      modules = [
        ./setup.nix
        {
          setup = {
            inherit username;
            hostname = "Alex-NixOS";
            isNixOS = true;

            desktopEnvironments = {
              background = {
                light = ./files/desktop-backgrounds/nixos-catppuccin-latte.png;
                dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato.png;
              };
              gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
              };
            };

            terminalTools = {
              theme = "catppuccin-macchiato";
              useThemeInTerminalItself = true;
              yt-dlp = true;
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
              hexchat = true;
              obsidian = true;
              rustdesk = true;
              supersonic = true;
              vlc = true;
              xremap = true;
            };
          };
        }
      ];
    };

  "pi@Bert-NixOS" = let
    system = "aarch64-linux";
  in
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = extraSpecialArgs // {inherit system;};
      modules = [
        ./setup.nix
        {
          setup = {
            username = "pi";
            hostname = "Bert-NixOS";
            isNixOS = true;
            terminalTools = {
              theme = "catppuccin-macchiato";
              btop.gpuSupport = false;
            };
            programming.miscTools.git-all = false;
          };
        }
      ];
    };

  "${username}@Sasha-NixOS" = let
    system = "x86_64-linux";
  in
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = extraSpecialArgs // {inherit system;};
      modules = [
        ./setup.nix
        {
          setup = {
            inherit username;
            hostname = "Sasha-NixOS";
            isNixOS = true;

            desktopEnvironments = {
              background = {
                light = ./files/desktop-backgrounds/nixos-catppuccin-latte.png;
                dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato.png;
              };
              cinnamon = {
                enable = true;
                mesonIcon = ./files/icons/nix-snowflake-black.svg;
                theme = {
                  gtk = "Mint-Y-Orange";
                  cursor = "Bibata-Original-Classic";
                };
              };
            };

            terminalTools = {
              theme = "catppuccin-macchiato";
              useThemeInTerminalItself = true;
              nvim = "small";
            };

            rclone = {
              enable = true;
              automounts = [
                {
                  remote = "OneDrive";
                  mountpoint = "/home/${username}/OneDrive";
                }
              ];
            };

            firefox = {
              enable = true;
              minimal = true;
            };

            miscPrograms = {
              handbrake = true;
              rustdesk = true;
              vlc = true;
            };
          };
        }
      ];
    };

  "rebecca@Sasha-NixOS" = let
    system = "x86_64-linux";
  in
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = extraSpecialArgs // {inherit system;};
      modules = [
        ./setup.nix
        {
          setup = {
            username = "rebecca";
            hostname = "Sasha-NixOS";
            isNixOS = true;

            desktopEnvironments = {
              background = {
                light = ./files/desktop-backgrounds/nixos-catppuccin-latte.png;
                dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato.png;
              };
              cinnamon = {
                enable = true;
                mesonIcon = ./files/icons/nix-snowflake-black.svg;
                theme = {
                  gtk = "Mint-Y-Orange";
                  cursor = "Bibata-Original-Classic";
                };
              };
            };

            terminalTools.nvim = "small";

            firefox = {
              enable = true;
              minimal = true;
            };

            miscPrograms = {
              rustdesk = true;
              vlc = true;
            };

            office = {
              libreoffice = true;
              onlyoffice = true;
            };
          };
        }
      ];
    };

  "${username}@Harold-NixOS" = let
    system = "x86_64-linux";
  in
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = extraSpecialArgs // {inherit system;};
      modules = [
        ./setup.nix
        {
          setup = {
            inherit username;
            hostname = "Harold-NixOS";
            isNixOS = true;
            isLaptop = true;

            desktopEnvironments = {
              background = {
                light = ./files/desktop-backgrounds/nixos-catppuccin-latte.png;
                dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato.png;
              };
              gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
              };
            };

            terminalTools = {
              theme = "catppuccin-macchiato";
              useThemeInTerminalItself = true;
              yt-dlp = true;
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
              hexchat = true;
              obsidian = true;
              rustdesk = true;
              supersonic = true;
              vlc = true;
              xremap = true;
            };
          };
        }
      ];
    };

  "${username}@VirtualBox-NixOS" = let
    system = "x86_64-linux";
  in
    home-manager.lib.homeManagerConfiguration {
      pkgs = mkPkgs system;
      extraSpecialArgs = extraSpecialArgs // {inherit system;};
      modules = [
        ./setup.nix
        {
          setup = {
            inherit username;
            hostname = "VirtualBox-NixOS";
            isNixOS = true;

            desktopEnvironments = {
              background = ./files/desktop-backgrounds/virtualbox.jpg;
              gnome = {
                enable = true;
                theme = "catppuccin-adaptive-macchiato-mauve";
              };
            };

            firefox = {
              enable = true;
              minimal = true;
            };

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

            terminalTools.nvim = "small"; # My custom themes and hotkeys, but no LSPs
            miscPrograms.xremap = false;
          };
        }
      ];
    };
}
