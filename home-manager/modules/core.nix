{
  pkgs,
  lib,
  config,
  inputs,
  ...
}: {
  home = {
    inherit (config.setup) username;
    homeDirectory = "/home/${config.setup.username}";

    # This value determines the Home Manager release that your configuration is
    # compatible with. This helps avoid breakage when a new Home Manager release
    # introduces backwards incompatible changes.
    #
    # You should not change this value, even if you update Home Manager. If you do
    # want to update the value, then make sure to first check the Home Manager
    # release notes.
    stateVersion = "23.11"; # Please read the comment before changing.

    packages = with pkgs; [
      # wl-clipboard
      xclip
    ];

    file = {
      ".inputrc".text = ''
        $include /etc/inputrc
        "\C-H": backward-kill-word
      '';
      ".XCompose".text = ''
        include "%L"
        <Multi_key> <b> <c> : "∵" # because
        <Multi_key> <t> <f> : "∴" # therefore
      '';
    };
  };

  nixpkgs.config = {
    # These are lists of allowed unfree and insecure packages respectively.
    # They are allowed on any host (since this is core.nix), but they're
    # only actually installed by certain modules.
    allowUnfreePredicate = pkg:
      builtins.elem (lib.getName pkg) [
        "discord"
        "libsciter" # For RustDesk
        "obsidian"

        # Firefox extensions
        "dashlane"
        "enhancer-for-youtube"
        "tampermonkey"

        # Microsoft fonts
        "corefonts"
        "vista-fonts"
      ];

    permittedInsecurePackages = [];
  };

  nix = {
    package = pkgs.lix;

    # Use these flake inputs for system-wide flake registry
    registry = lib.mkForce (lib.mapAttrs (_: value: {flake = value;}) inputs);

    # Enable flakes
    settings.experimental-features = ["nix-command" "flakes"];
  };

  targets.genericLinux.enable = !config.setup.isNixOS;
}
