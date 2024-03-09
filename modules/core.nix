{pkgs, ...}: {
  nix = {
    # Enable flakes
    extraOptions = "experimental-features = nix-command flakes";

    # Garbage collect old packages every week
    gc = {
      automatic = true;
      dates = "weekly";
      options = "--delete-older-than 7d";
    };
  };

  # Allow unfree packages (drivers and hardware stuff)
  nixpkgs.config.allowUnfree = true;

  networking = {
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
    openssh.enable = true;

    # Audio with pipewire
    pipewire = {
      enable = true;
      alsa.enable = true;
      alsa.support32Bit = true;
      pulse.enable = true;
      # jack.enable = true;
    };

    # Enable CUPS for printing
    printing.enable = true;

    xserver = {
      enable = true;

      # Enable GNOME system-wide
      displayManager.gdm.enable = true;
      desktopManager.gnome.enable = true;

      # Use British keyboard in graphical sessions
      layout = "gb";
      # Use caps lock as escape, always use num lock, terminate the X server
      # with ctrl + alt + backspace, and use the menu key as the compose key
      xkb.options = "caps:escape,numpad:mac,terminate:ctrl_alt_bksp,compose:menu";
    };
  };

  # Use British keyboard in TTYs
  console.keyMap = "uk";

  # Enable sound
  sound.enable = true;
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;

  environment.systemPackages = with pkgs; [
    git
    vim
    wget
  ];

  users.users.dyson = {
    isNormalUser = true;
    description = "Dyson";
    extraGroups = ["networkmanager" "wheel"];
    packages = with pkgs; [
      firefox
    ];
  };
}
