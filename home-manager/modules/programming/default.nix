{
  imports = [
    ./android.nix
    ./haskell.nix
    ./jetbrains.nix
    ./julia.nix
    ./nix.nix
    ./misc.nix
    ./python.nix
    ./rust.nix
  ];

  setup.impermanence.keepFiles = [ ".config/gdb/gdbinit" ];
}
