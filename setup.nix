{
  lib,
  config,
  ...
}: let
  inherit (lib) mkOption types;

  defaultTrue = mkOption {
    default = true;
    type = types.bool;
  };
  defaultFalse = mkOption {
    default = false;
    type = types.bool;
  };
in {
  imports = [
    ./modules/core.nix

    ./modules/graphical
    ./modules/laptop

    ./modules/androidTools
    ./modules/desktopEnvironments
    ./modules/displayManagers
    ./modules/development
    ./modules/gaming
    ./modules/openRGB
    ./modules/homeServer
    ./modules/pam
    ./modules/printing
    ./modules/secrets
    ./modules/uinput
    ./modules/users
    ./modules/virtualBox
  ];

  options.setup = {
    hostname = mkOption {
      type = types.nonEmptyStr;
    };
    isGraphical = defaultTrue;
    isLaptop = defaultFalse;

    # === Basic system config
    ssh = {
      enable = defaultTrue;
      mosh = defaultTrue;
    };

    allowUnfree = defaultFalse;

    # === Android dev
    androidTools = {
      enable = defaultFalse;
      droidcam = defaultTrue;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
      };
    };

    # === Desktop stuff
    profilePictures = mkOption {
      type = types.submodule {
        freeformType = types.attrsOf types.path;
      };
      default = {};
    };

    desktopEnvironments = {
      cinnamon = {
        enable = defaultFalse;
      };
      gnome = {
        enable = defaultFalse;
        minimal = defaultTrue;
      };
    };

    displayManagers = {
      gdm = {
        enable = defaultFalse;
      };
      sddm = {
        enable = defaultFalse;
        theme = mkOption {
          type = types.nullOr types.package;
        };
      };
    };

    # === Development
    binfmt = {
      aarch64 = defaultFalse;
    };

    # === Gaming
    gaming = {
      enable = defaultFalse;
      steam = {
        enable = defaultTrue;
        enableProtonGE = defaultTrue;
      };
      lutris = defaultTrue;
      emulators = {
        ps3 = defaultTrue;
      };
    };

    openRGB = {
      enable = defaultFalse;
      usePlugins = defaultTrue;
    };

    # === Home server
    homeServer = {
      enable = defaultFalse;

      domainName = mkOption {
        type = types.nonEmptyStr;
      };
      dataRoot = mkOption {
        type = types.nonEmptyStr;
      };

      # All the ports used by different services
      ports = let
        port = num:
          mkOption {
            type = types.port;
            default = num;
          };
      in {
        homepage = port 42731;

        adguardhome = {
          http = port 3000;
          https = port 3001;
          dnsOverTls = port 853; # TCP
          dnsOverQuic = port 853; # UDP
        };

        mediaServer = {
          calibre = {
            server = port 8082;
            web = port 8083;
          };
          jellyfin = {
            http = port 8096;
            https = port 8920;
          };
          navidrome = port 4533;

          lidarr = port 8686;
          radarr = port 7878;
          readarr = port 8787;
          sonarr = port 8989;

          prowlarr = port 9696;
          transmission = port 9091;
        };

        personalProjects = {
          winter-wonderlights = {
            normal = port 23120;
            scanner = port 23121;
          };
        };
      };

      adguardhome.enable = defaultFalse;

      homeAutomation = {};

      mediaServer = {
        enable = defaultFalse;

        mediaRoot = mkOption {
          type = types.nonEmptyStr;
          default = "${config.setup.homeServer.dataRoot}/media";
        };

        books = defaultTrue;
        music = defaultTrue;
        movies = defaultTrue;
        telly = defaultTrue;

        transmission = {
          ovpnName = mkOption {
            type = types.nonEmptyStr;
            description = ''
              The unqualified name of the OpenVPN config file to be used for transmission.

              All files are expected to be /etc/openvpn/something.ovpn, so if this option was set to "gh_hotspotshield", then the relevant systemd service would expect to find /etc/openvpn/gb_hotspotshield.ovpn".
            '';
          };
          thirdOctet = mkOption {
            type = types.ints.between 1 255;
            default = 5;
            description = ''
              We use a veth system to connect the normal internet to the network namespace used to keep transmission in a VPN. The veth interfaces have the IP addresses 192.168.X.1 and 192.168.X.2, where X is this thirdOctet option.
            '';
          };
        };
      };

      personalProjects = {
        enable = defaultFalse;

        tictactoe = defaultTrue;
        winter-wonderlights = defaultTrue;
        wordle = defaultTrue;
      };
    };

    # === Passwords
    pamShortenFailDelay = {
      enable = defaultTrue;
      microseconds = mkOption {
        type = types.ints.unsigned;
        default = 150000; # 150 ms
      };
    };

    # === Printing
    printing = {
      enable = defaultFalse;
      networkAutoDiscovery = defaultTrue;
      scanning = defaultTrue;

      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
      };

      specificPrinters = {
        canonPixmaMG3250 = defaultFalse;
      };
    };

    # === Secrets
    secrets = {
      enable = defaultTrue;
      userPasswords = {
        enable = defaultTrue;

        # Note that enabling any of these DOES NOT enable the user. Use
        # `setup.users` to enable users.
        users = {
          dyson = defaultTrue;
          pi = defaultTrue;
        };
      };
      networking = {
        enable = defaultFalse;
        simpleWifiNetworkNames = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = ["HOME"];
          description = ''The names of the simple WiFi networks to use. Each name here should have entries of the form "<name>_SSID" and "<name>_PSK" in the secret environment.env file.'';
        };
      };
      vpn = {
        enable = defaultFalse;
        vpns = mkOption {
          type = types.listOf (types.submodule {
            options = {
              vpnName = mkOption {
                type = types.nonEmptyStr;
              };
              users = mkOption {
                type = types.listOf types.nonEmptyStr;
              };
            };
          });
          default = [
            {
              vpnName = "ch_hotspotshield";
              users = ["dyson"];
            }
            {
              vpnName = "gb_hotspotshield";
              users = ["dyson"];
            }
          ];
        };
      };
      tailscale.enable = defaultTrue;
      cachix.enable = defaultTrue;
    };

    # === uinput
    # We need uinput for xremap and weylus
    uinput = {
      enable = defaultFalse;
      users = mkOption {
        type = types.listOf types.nonEmptyStr;
        default = [];
      };
    };

    # === Users
    users = {
      dyson = defaultTrue;
      pi = defaultFalse;
    };

    # === VirtualBox
    virtualBox = {
      guest.enable = defaultFalse;
      host = {
        enable = defaultFalse;
        users = mkOption {
          type = types.listOf types.nonEmptyStr;
          default = [];
        };
      };
    };
  };
}
