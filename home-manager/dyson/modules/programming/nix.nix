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
      nix-output-monitor
      nix-tree
      nvd
      statix
      unstable.nh
    ];
  };
}
