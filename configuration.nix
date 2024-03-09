{lib, ...}: let
  machineMap = {
    "4539ca6a-89e3-354d-aa67-c8501883e47e" = ./machines/vbox.nix;
  };
  machine =
    machineMap
    .${
      lib.removeSuffix "\n" (builtins.readFile /sys/class/dmi/id/product_uuid)
    };
in {
  imports = [machine];
  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Define a user account. Don't forget to set a password with ‘passwd’.

  # List packages installed in system profile. To search, run:
  # $ nix search wget

  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;
}
