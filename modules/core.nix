{
  pkgs,
  lib,
  config,
  ...
}: let
  cfg = config.setup;
in {
  system.stateVersion = "23.11";

  nix = {
    settings = {
      # Keep the nix store optimised
      auto-optimise-store = true;

      # Enable flakes
      experimental-features = ["nix-command" "flakes"];
    };

    # Garbage collect old packages every two weeks
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 14d";
    };
  };

  # Allow unfree packages (drivers and hardware stuff)
  nixpkgs.config.allowUnfree = cfg.allowUnfree;

  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      # Gaming
      "steam"
      "steam-original"
      "steam-run"
      "xow_dongle-firmware" # Needed for xone driver
    ];

  networking = {
    hostName = cfg.hostname;
    firewall.enable = true;
    networkmanager.enable = true;
  };

  time.timeZone = "Europe/London";

  i18n = {
    defaultLocale = "en_GB.UTF-8";
    extraLocaleSettings = {
      LC_ADDRESS = "en_GB.UTF-8";
      LC_IDENTIFICATION = "en_GB.UTF-8";
      LC_MEASUREMENT = "en_GB.UTF-8";
      LC_MONETARY = "en_GB.UTF-8";
      LC_NAME = "en_GB.UTF-8";
      LC_NUMERIC = "en_GB.UTF-8";
      LC_PAPER = "en_GB.UTF-8";
      LC_TELEPHONE = "en_GB.UTF-8";
      LC_TIME = "en_GB.UTF-8";
    };
  };

  programs.mosh.enable = cfg.ssh.mosh;

  services = {
    openssh = {
      inherit (cfg.ssh) enable;
      settings = {
        PermitRootLogin = "no";
        PasswordAuthentication = false;
      };
    };

    # Enable CUPS for printing
    printing.enable = cfg.enablePrinting;
  };

  # Use British keyboard in TTYs
  console.keyMap = "uk";

  environment.systemPackages = with pkgs; [
    busybox
    coreutils
    file
    git
    vim
    wget
  ];
}
