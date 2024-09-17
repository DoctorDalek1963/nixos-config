{osConfig}: {
  Alex-NixOS.dyson.setup = {
    username = "dyson";
    inherit (osConfig.setup) hostname;

    desktopEnvironments = {
      background = {
        light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
        dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
      };
      gnome = {
        enable = true;
        theme = "catppuccin-adaptive-macchiato-mauve";
      };
    };

    terminal = {
      theme = "catppuccin-macchiato";
      tools.yt-dlp = true;
    };

    firefox.enable = true;

    rclone = {
      enable = true;
      automounts = [
        {
          remote = "OneDrive";
          mountpoint = "/home/dyson/OneDrive";
        }
      ];
    };

    maths.enable = true;

    programming = {
      haskell = true;
      python = true;
      rust = true;
    };

    miscPrograms = {
      feishin = true;
      hexchat = true;
      obsidian = true;
      rustdesk = true;
      vlc = true;
      xremap = true;
    };
  };

  Bert-NixOS.pi.setup = {
    username = "pi";
    inherit (osConfig.setup) hostname;
    terminal = {
      theme = "catppuccin-macchiato";
      tools = {
        btop.gpuSupport = false;
        git-all = false;
        nvim = "tiny";
      };
    };
  };

  Sasha-NixOS = {
    dyson.setup = {
      username = "dyson";
      inherit (osConfig.setup) hostname;

      desktopEnvironments = {
        background = {
          light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
          dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
        };
        cinnamon = {
          enable = true;
          menuIcon = ./files/icons/nix-snowflake-black.svg;
          theme = {
            gtk = "Mint-Y-Orange";
            cursor = "Bibata-Original-Classic";
          };
        };
      };

      terminal = {
        theme = "catppuccin-macchiato";
        tools.nvim = "small";
      };

      rclone = {
        enable = true;
        automounts = [
          {
            remote = "OneDrive";
            mountpoint = "/home/dyson/OneDrive";
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

    rebecca.setup = {
      username = "rebecca";
      inherit (osConfig.setup) hostname;

      desktopEnvironments = {
        background-slideshow-path = "/home/rebecca/Pictures/Wallpaper Slideshow";
        cinnamon = {
          enable = true;
          menuIcon = ./files/icons/nix-snowflake-black.svg;
          theme = {
            gtk = "Mint-Y-Orange";
            cursor = "Bibata-Original-Classic";
          };
        };
      };

      terminal.tools.nvim = "small";

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
  };

  Harold-NixOS.dyson.setup = {
    username = "dyson";
    inherit (osConfig.setup) hostname;
    isLaptop = true;

    desktopEnvironments = {
      background = {
        light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
        dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
      };
      gnome = {
        enable = true;
        theme = "catppuccin-adaptive-macchiato-mauve";
      };
    };

    terminal = {
      theme = "catppuccin-macchiato";
      tools.yt-dlp = true;
    };

    firefox.enable = true;

    rclone = {
      enable = true;
      automounts = [
        {
          remote = "OneDrive";
          mountpoint = "/home/dyson/OneDrive";
        }
      ];
    };

    maths.enable = true;

    programming = {
      haskell = true;
      python = true;
      rust = true;
    };

    miscPrograms = {
      discord = true;
      feishin = true;
      hexchat = true;
      obsidian = true;
      rustdesk = true;
      vlc = true;
      xremap = true;
    };
  };

  VirtualBox-NixOS.dyson.setup = {
    username = "dyson";
    inherit (osConfig.setup) hostname;

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
    #       mountpoint = "/home/dyson/OneDrive";
    #       readonly = true;
    #     }
    #   ];
    # };
  };
}
