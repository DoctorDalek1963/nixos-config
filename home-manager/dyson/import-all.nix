{inputs, ...}: let
  files = [
    ./setup.nix
    ./consts.nix

    ./modules/core.nix

    # Shells
    ./modules/shells/bash.nix

    # Terminal tools
    ./modules/terminalTools/bat.nix
    ./modules/terminalTools/btop.nix
    ./modules/terminalTools/delta.nix
    ./modules/terminalTools/fd.nix
    ./modules/terminalTools/git.nix
    ./modules/terminalTools/nvim.nix
    ./modules/terminalTools/ripgrep.nix

    # Secrets
    ./modules/secrets/provisioning.nix
    ./modules/secrets/gnome-keyring.nix

    # Desktop environments
    # Each default.nix file here also imports any other necessary nix files
    ./modules/desktopEnvironments/gnome/default.nix

    ./modules/firefox/default.nix

    # Programming
    ./modules/programming/miscTools.nix
    ./modules/programming/haskell.nix
    ./modules/programming/julia.nix
    ./modules/programming/nix.nix
    ./modules/programming/python.nix
    ./modules/programming/rust.nix

    ./modules/maths/default.nix

    ./modules/gaming.nix

    # Misc programs
    ./modules/miscPrograms/discord.nix
  ];
  other-modules = [inputs.sops-nix.homeManagerModules.sops];
in {
  imports = files ++ other-modules;
}
