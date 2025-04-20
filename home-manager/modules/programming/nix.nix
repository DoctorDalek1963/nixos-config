{
  pkgs,
  lib,
  config,
  ...
}: {
  config = lib.mkIf config.setup.programming.nix {
    home.packages = with pkgs; [
      nh
      nix-output-monitor
      nix-tree
    ];

    setup.terminal.shellAliases = {
      n = "nix";
      nhos = "FLAKE=/etc/nixos ${pkgs.nh}/bin/nh os";
      nhcl = "${pkgs.nh}/bin/nh clean all --nogcroots";
    };
  };
}
