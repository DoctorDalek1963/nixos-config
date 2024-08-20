{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.nix {
    home.packages = with pkgs; [
      alejandra
      deadnix
      nh
      nix-output-monitor
      nix-tree
      nvd
      statix
    ];

    setup.terminal.shellAliases = {
      n = "nix";
      nhos = "FLAKE=/etc/nixos ${pkgs.nh}/bin/nh os";
    };
  };
}
