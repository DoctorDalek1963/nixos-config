{
  pkgs,
  config,
  ...
}: let
  cfg = config.setup;
in {
  system.stateVersion = "23.11";

  nix = {
    # Enable flakes
    settings.experimental-features = ["nix-command" "flakes"];

    # Garbage collect old packages every week
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages (drivers and hardware stuff)
  nixpkgs.config.allowUnfree = cfg.allowUnfree;

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

    # Audio with pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;
    };

    # Enable CUPS for printing
    printing.enable = cfg.enablePrinting;

    xserver = {
      enable = true;
      # Use British keyboard in graphical sessions
      layout = "gb";
    };
  };

  # Use British keyboard in TTYs
  console.keyMap = "uk";

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    busybox
    coreutils
    file
    git
    vim
  ];

  users = {
    mutableUsers = !config.setup.secrets.userPasswords.enable;

    users.dyson = {
      isNormalUser = true;
      description = "Dyson";
      initialPassword =
        if config.setup.secrets.userPasswords.enable
        then null
        else "changeme";
      extraGroups =
        ["networkmanager" "wheel"]
        ++ (
          if config.setup.virtualBoxHost
          then ["vboxusers"]
          else []
        );
    };
  };
}
