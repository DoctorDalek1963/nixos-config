{inputs, ...}: let
  files = [
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
  ];
  other-modules = [inputs.sops-nix.homeManagerModules.sops];
in {
  imports = files ++ other-modules;
}
