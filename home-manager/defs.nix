{
  Alex-NixOS.dyson.setup = {
    username = "dyson";

    desktopEnvironments = {
      background = {
        light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
        dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
      };
      gnome.theme = "catppuccin-adaptive-macchiato-mauve";
      hyprland.theme = "catppuccin-macchiato-mauve";
    };

    terminal.tools.yt-dlp = true;

    librewolf.enable = true;

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

      jetbrains = true;
    };

    misc = {
      programs = {
        feishin = true;
        hexchat = true;
        ms-teams = true;
        obsidian = true;
        rustdesk = true;
        vlc = true;
      };
      services.easyeffects = true;
    };

    office.onlyoffice = true;
  };

  Bert-NixOS.pi.setup = {
    username = "pi";

    terminal = {
      tools = {
        btop.gpuSupport = false;
        git-all = false;
        nvim = "tiny";
      };
    };
  };

  # Olivia-NixOS = {
  #   dyson.setup = {
  #     username = "dyson";
  #
  #     desktopEnvironments = {
  #       background = {
  #         light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
  #         dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
  #       };
  #       cinnamon = {
  #         menuIcon = ./files/icons/nix-snowflake-black.svg;
  #         theme = {
  #           gtk = "Mint-Y-Orange";
  #           cursor = "Bibata-Original-Classic";
  #         };
  #       };
  #     };
  #
  #     terminal.tools.nvim = "small";
  #
  #     rclone = {
  #       enable = true;
  #       automounts = [
  #         {
  #           remote = "OneDrive";
  #           mountpoint = "/home/dyson/OneDrive";
  #         }
  #       ];
  #     };
  #
  #     librewolf = {
  #       enable = true;
  #       minimal = true;
  #     };
  #
  #     misc.programs = {
  #       handbrake = true;
  #       rustdesk = true;
  #       vlc = true;
  #     };
  #   };
  #
  #   rebecca.setup = {
  #     username = "rebecca";
  #
  #     desktopEnvironments = {
  #       background-slideshow-path = "/home/rebecca/Pictures/Wallpaper Slideshow";
  #       cinnamon = {
  #         menuIcon = ./files/icons/nix-snowflake-black.svg;
  #         theme = {
  #           gtk = "Mint-Y-Orange";
  #           cursor = "Bibata-Original-Classic";
  #         };
  #       };
  #     };
  #
  #     terminal.tools.nvim = "small";
  #
  #     librewolf = {
  #       enable = true;
  #       minimal = true;
  #     };
  #
  #     misc.programs = {
  #       rustdesk = true;
  #       vlc = true;
  #     };
  #
  #     office = {
  #       libreoffice = true;
  #       onlyoffice = true;
  #     };
  #   };
  # };

  Sasha-NixOS.dyson = {
    setup = {
      username = "dyson";

      terminal = {
        tools = {
          git-all = false;
          nvim = "small";
        };
      };
    };

    # For some unknown reason, bindfs seems to often (but not always) create
    # the mountDir with mode 000 and owned by root:root. This obviously breaks
    # a lot of things. Using symlinks doesn't completely fix the problem but it
    # seems to help significantly. Now after booting, /home/dyson/.ssh is owned
    # by root:root but it stops home-manager-dyson.service, so I just change
    # the ownership of that directory and restart the service and everything's
    # fine. Maybe the user doesn't exist early enough? Because once that error
    # is fixed, every other persistant directory works as intended. What
    # service or script is creating /home/dyson/.ssh and when?
    home.persistence."/persist/home/dyson".defaultDirectoryMethod = "symlink";
  };

  Harold-NixOS.dyson.setup = {
    username = "dyson";

    desktopEnvironments = {
      background = {
        light = ./files/desktop-backgrounds/nixos-catppuccin-latte-gay.png;
        dark = ./files/desktop-backgrounds/nixos-catppuccin-macchiato-gay.png;
      };
      gnome.theme = "catppuccin-adaptive-macchiato-mauve";
      hyprland.theme = "catppuccin-macchiato-mauve";
    };

    terminal.tools.yt-dlp = true;

    librewolf.enable = true;

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

    misc = {
      programs = {
        feishin = true;
        hexchat = true;
        ms-teams = true;
        obsidian = true;
        rustdesk = true;
        vlc = true;
      };
      services.easyeffects = true;
    };

    office.onlyoffice = true;
  };

  VirtualBox-NixOS.dyson.setup = {
    username = "dyson";

    desktopEnvironments = {
      background = ./files/desktop-backgrounds/virtualbox.jpg;
      gnome.theme = "catppuccin-adaptive-macchiato-mauve";
    };

    librewolf = {
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
