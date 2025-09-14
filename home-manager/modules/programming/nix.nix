{
  pkgs,
  lib,
  config,
  ...
}:
{
  config = lib.mkIf config.setup.programming.nix {
    home.packages = with pkgs; [
      nix-output-monitor
      nix-tree
      nixpkgs-reviewFull
      nh
    ];

    setup.terminal.shellAliases = {
      n = "nix";
      nhos = "NH_FLAKE=/etc/nixos nh os";
      nhcl = "nh clean all --keep 3 --nogcroots";
      nrpl = "nix repl --file '<nixpkgs>'";
    };
  };
}
