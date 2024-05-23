{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: let
  cfg = config.setup;
in {
  system.stateVersion = "23.11";

  nix = {
    # Registry and channel settings were taken from
    # https://github.com/jnsgruk/nixos-config/blob/e7f63ca65cc221760ab5e5e6b92e1777c7a90a87/host/default.nix#L51-L59

    # Use these flake inputs for system-wide flake registry
    registry = lib.mkForce (lib.mapAttrs (_: value: {flake = value;}) inputs);

    # Use these flake inputs for nix channels for old commands
    nixPath = lib.mkForce (
      lib.mapAttrsToList (key: value: "${key}=${value.to.path}") config.nix.registry
    );

    settings = {
      # Keep the nix store optimised
      auto-optimise-store = true;

      # Enable flakes
      experimental-features = ["nix-command" "flakes"];
    };

    # Garbage collect old packages every week
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

  services = {
    openssh = {
      enable = cfg.enableSsh;
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
